public with sharing virtual class skedPageControllerBase {
    
  private skedComponentControllerBase myComponentController;
  private Map<String, skedComponentControllerBase>componentControllerMap; //new
    
  public virtual skedComponentControllerBase getMyComponentController() {
    return myComponentController;
  }

  //new getter for the hashmap
  public virtual Map<String, skedComponentControllerBase> getComponentControllerMap(){
    return componentControllerMap;
  }
  //new method for putting value in the hashmap
  public virtual void setComponentControllerMap(String key, skedComponentControllerBase compController){
    if(componentControllerMap == null)
      componentControllerMap = new Map<String, skedComponentControllerBase>();
    componentControllerMap.put(key,compController); 
  }

  public virtual void setComponentController(skedComponentControllerBase compController) {
    myComponentController = compController;
  }
    
  public skedPageControllerBase getThis() {
    return this;
  }
    
}