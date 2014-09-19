package cn.kuwo.sing.ui.adapter;

import cn.kuwo.sing.fragment.SquareStarFragment;
import cn.kuwo.sing.fragment.SquareHotFragment;
import cn.kuwo.sing.fragment.SquareLattestFragment;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.ViewGroup;


public class SquarePagerAdapter extends FragmentPagerAdapter {
	private String[] mTitles = null;
	private ViewPager mViewPager;
	private boolean mHasRecommond = false;
	
	public SquarePagerAdapter(FragmentManager fm, String[] titles, ViewPager viewPager) {
		super(fm);
		mTitles = titles;
		mViewPager = viewPager;
	}
	
	
	@Override
	public CharSequence getPageTitle(int position) {
		return mTitles[position];
	}
	
	@Override
	public Fragment getItem(int arg0) {
		Fragment fragment = null;
		switch (arg0) {
		case 0:
			fragment = new SquareHotFragment(); //热门作品
			break;
		case 1:
			fragment = new SquareStarFragment(); // K歌达人
			break;
		case 2: 
			fragment = new SquareLattestFragment(); //最新作品
			break;
		default:
			break;
		}
		return fragment;
	}

	@Override
	public int getCount() {
		return mTitles.length;
	}

	public void setHasRecommond(boolean b){
		mHasRecommond = b;
	}
}
