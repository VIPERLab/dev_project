package cn.kuwo.base.codec;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import android.content.Context;

import com.coremedia.iso.IsoFile;
import com.googlecode.mp4parser.authoring.Movie;
import com.googlecode.mp4parser.authoring.Track;
import com.googlecode.mp4parser.authoring.builder.DefaultMp4Builder;
import com.googlecode.mp4parser.authoring.tracks.AACTrackImpl;

public class AACToM4A {

    private static Context context;

    public static Context getContext() {
        return context;
    }

    public void convert(Context context, String infile, String outfile) throws IOException {
        AACToM4A.context = context;

        FileInputStream input = new FileInputStream(infile);

        System.err.println("well you got " + input.available());
        Movie movie = new Movie();

        Track audioTrack = new AACTrackImpl(input.getChannel());
        movie.addTrack(audioTrack);

        IsoFile out = new DefaultMp4Builder().build(movie);
        FileOutputStream output = new FileOutputStream(outfile);
        out.getBox(output.getChannel());
        output.close();
    }

}
