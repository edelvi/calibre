public class Queue {
    
    private List<Object> fifoList = new List<Object>();
    
    public Object pop(){
        if(fifoList.size() > 0){
            return fifoList.remove(0);
        }
        return null;
    }
    
    public void push(Object obj){
        fifoList.add(obj);
    }
    
    public void clearQueue(){
        fifoList.clear();
    }
    
    public Integer size(){
        return fifoList.size();
    }
}