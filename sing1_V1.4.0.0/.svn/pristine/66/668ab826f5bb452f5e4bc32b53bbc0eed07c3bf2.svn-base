#pragma once

//存储wav的先进先出的buffer, Added by Wang Lei, Mar 5th, 2008
#define sample_t short
typedef long LONG;

class wav_buf
{
public:
	struct node
	{
		sample_t * data;	//数据的指针
		int data_len;		//数据的长度
		int begin_pos;		//有效数据开始的位置为data + begin_pos
		node * next;		//指向下一个node的指针
	};
private:
	node * first;
	node * last;
	int	total_node_num;
	int total_data_len;
	int record_pos;	//当前buf中开始位置的数据在整个录制的数据中的位置
public:
	wav_buf();
	~wav_buf();
	int add(sample_t * adddata, int len);
	int remove_from_head(sample_t * out, int len);
	int get_from_head(sample_t * out, int len);
	inline LONG get_data_len(){return total_data_len;}
	void remove_all();
};