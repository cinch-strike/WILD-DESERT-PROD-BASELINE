public with sharing virtual class skedComponentControllerBase {
  //the new property
  public String key{ get;
    set{
      if(value != null){
         Key  = value;
        if(pageController != null)
            pageController.setComponentControllerMap(Key, this);
      }
    }
  }

  public skedPageControllerBase pageController { get; 
    set {
      if (value != null) {
    pageController = value;
    pageController.setComponentController(this);
      }
    }
  }
}