package com.ifeng.news2.bean;

import java.util.ArrayList;

import java.io.Serializable;

public class ListItems implements Serializable {

  private static final long serialVersionUID = -1565998705535709830L;

  private ArrayList<ListItem> item = new ArrayList<ListItem>();

  public ArrayList<ListItem> getItem() {
    return item;
  }

  public void setItem(ArrayList<ListItem> item) {
    this.item = item;
  }
  
}
