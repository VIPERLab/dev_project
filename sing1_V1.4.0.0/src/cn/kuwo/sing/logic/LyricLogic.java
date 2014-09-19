package cn.kuwo.sing.logic;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.Iterator;

import org.apache.commons.io.FileUtils;
import cn.kuwo.framework.dir.DirectoryManager;
import cn.kuwo.framework.utils.IOUtils;
import cn.kuwo.sing.context.DirContext;
import cn.kuwo.sing.util.lyric.Lyric;
import cn.kuwo.sing.util.lyric.Sentence;
import cn.kuwo.sing.util.lyric.Word;

public class LyricLogic {
	
	public Word findWord(long position, Sentence sentence){
		Collection<Word> words = sentence.getWords();
		Word currentword = null,lastword= null;
		for(Iterator<Word> it = words.iterator(); it.hasNext(); ) {
			currentword = (Word) it.next();
			if(position < currentword.getTimestamp())
				break;
			lastword = currentword;
		}
		
		if (lastword == null)
			return null;
		
		return lastword;
	}
	
	public String findHighlightWords(long position, Sentence sentence){
		Collection<Word> words = sentence.getWords();
		Word currentword,lastword= null;
		
		for(Iterator<Word> it = words.iterator(); it.hasNext(); ) {
			currentword = (Word) it.next();
			if(position < currentword.getTimestamp())
				break;
			lastword = currentword;
		}
		
		if (lastword == null)
			return null;
		
		return sentence.getContent().substring(0, lastword.getIndex());
	}
	
	public static final int SENTENCE_RESULT_NEXT = 1;
	public static final int SENTENCE_RESULT_NOW = 0;
	public static final int SENTENCE_RESULT_PREVIOUS = -1;
	
	public Sentence findSentence(long position, Lyric lyric, int sentenceResultType){   //当前时间为两句之间时，sentenceResultType决定其返回值 ,<0 返回上一句，=0返回null, >0返回下一句
//		当歌词上一句与下一句叠加时，返回的是下一句
		Collection<Sentence> sentences = lyric.getSentences();
		Sentence currentsentence,lastsentence = null;
		
		for(Iterator<Sentence> it = sentences.iterator(); it.hasNext(); ) {
			currentsentence = (Sentence) it.next();
			if(position < currentsentence.getTimestamp()){
				if (lastsentence == null)
					return sentences.iterator().next();
				
				else if(position > lastsentence.getTimestamp()+lastsentence.getTimespan()){
					
					if(sentenceResultType < 0)
					   return lastsentence;
					else if(sentenceResultType == 0)
						return null;
					else if( sentenceResultType > 0)
						return currentsentence;
				}
				else{
					return lastsentence;
				}
			}
			
			lastsentence = currentsentence;
		}
		
		return lastsentence;
	}
	
	// 返回时间点对就的句子的索引
	public int findSentenceIndex(long position, Lyric lyric){ 
		
		Collection<Sentence> sentences = lyric.getSentences();
		Sentence currentsentence = null;
		int i = -1;
		
		for(Iterator<Sentence> it = sentences.iterator(); it.hasNext(); ) {
			currentsentence = (Sentence) it.next();
			if (currentsentence.getTimestamp() > position)
				break;
			i ++;
		}
		
		return i;
	}
	
	public void saveFile(byte[] bytes, String rid, int type) throws IOException{
		
		ByteArrayInputStream in = new ByteArrayInputStream(bytes);
		byte[] data = IOUtils.readLeftBytes(in);
		in.close();
		String expend = "";
		switch(type){
		case 0:
			expend = "lrc";
			break;
		case 1:
			expend = "lrcx";
			break;
		case 2:
			expend = "kdtx";
			break;
		}
		
		String fileName = rid + "." + expend;
		File path = DirectoryManager.getFile(DirContext.LYRICS,fileName);
		FileUtils.writeByteArrayToFile(path, data);
	}
	
	public boolean isKdtx(Lyric lyric) {
		if (lyric == null)
			return false;
		
		return lyric.getType() == Lyric.LYRIC_TYPE_KDTX;
	}
	
	public String findNextSentenceContent(int index, Lyric lyric){
		
		//求下句歌词的内容
		Collection<Sentence> sentences = lyric.getSentences();
		Sentence currentsentence = null;
		String content = "";
		int i = 0;
		for(Iterator<Sentence> it = sentences.iterator(); it.hasNext();  ) {
			currentsentence = (Sentence) it.next();
			if(i == index+1){
				content = content + currentsentence.getContent();
				break;
			}
			i++;
		}
		return content;
	}
	
	public String findWordContent(int index, Sentence sentence){
		
		//求某时间字之前的该句字内容
		Collection<Word> words = sentence.getWords();
		Word currentword = null;
		String content = "";
		int i = 0;
		for(Iterator<Word> it = words.iterator(); it.hasNext(); ) {
			currentword = (Word) it.next();
			if(i == index)
				break;
			content = content + currentword.getContent();
			i++;
		}
		return content;
	}
}
