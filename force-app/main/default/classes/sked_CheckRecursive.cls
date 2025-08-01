public Class sked_CheckRecursive{
    private static boolean run = true;
    
    public static boolean runOnce(){
        if(run){
             run=false;
         
        return true;
        }else{
            return run; }
    }
    
    private static boolean run2 = true;
    
    public static boolean run2Once(){
        if(run2){
             run2=false;
         
        return true;
        }else{
            return run2; }
    }
    
}