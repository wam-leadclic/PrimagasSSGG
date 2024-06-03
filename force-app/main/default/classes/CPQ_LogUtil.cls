public class CPQ_LogUtil {
    
    public static void debug(String s){
        if(CPQ_Settings.AreLogsEnabled){
            System.debug(s);
        }
    }

}