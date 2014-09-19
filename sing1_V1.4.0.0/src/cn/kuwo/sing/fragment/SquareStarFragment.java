package cn.kuwo.sing.fragment;

import java.util.List;

import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.MTV;
import cn.kuwo.sing.business.ListBusiness;
import cn.kuwo.sing.context.Constants;
import cn.kuwo.sing.ui.adapter.SquareMtvObjectAdapter;
import cn.kuwo.sing.util.AnimateFirstDisplayListener;
import cn.kuwo.sing.util.PageDataHandler;

import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.handmark.pulltorefresh.library.PullToRefreshBase.OnRefreshListener;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.AdapterView.OnItemClickListener;

public class SquareStarFragment extends Fragment {
	private View mContentView;
	private PullToRefreshListView lvFragmentSquareStar;
	private ListBusiness mListBusiness;
	private SquareMtvObjectAdapter mMtvObjectAdapter;
	private int mCurrentPage;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	}
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		mContentView = inflater.inflate(R.layout.square_fragment_star, null);
		return mContentView;
	}
	
	private void initData() {
		mListBusiness = new ListBusiness();
	}
	
	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		initData();
		initView();
		obtainData(1);
	}
	
	private void initView() {
		lvFragmentSquareStar = (PullToRefreshListView) getActivity().findViewById(R.id.lvFragmentSquareStar);		
		mMtvObjectAdapter = new SquareMtvObjectAdapter(getActivity(),Constants.FLAG_SUPER_STAR);
		lvFragmentSquareStar.setOnRefreshListener(new OnRefreshListener<ListView>() {

			@Override
			public void onRefresh(PullToRefreshBase<ListView> refreshView) {
				switch(refreshView.getCurrentMode()){
				case PULL_FROM_START:
					obtainData(1);
					break;
				case PULL_FROM_END:
					obtainData(++mCurrentPage);
					break;

				default:
					break;
				}
			}
			
		});
		
	}
	
	private void obtainData(int Page) {
		mCurrentPage = Page;
		mListBusiness.getSquareSuperStar(Page, 24, new SquarePageDataHandler());
	}
	
	private class SquarePageDataHandler extends PageDataHandler<MTV> {

		@Override
		public void onSuccess(List<MTV> data) {
			lvFragmentSquareStar.onRefreshComplete();
			if (mCurrentPage == 1){
				mMtvObjectAdapter.clearImageObjectList();
			}
			mMtvObjectAdapter.setImageObjectData(data);
			lvFragmentSquareStar.setAdapter(mMtvObjectAdapter);
		}
		
		@Override
		public void onFailure(Throwable error, String content) {
			lvFragmentSquareStar.onRefreshComplete();
		}

	}
}
