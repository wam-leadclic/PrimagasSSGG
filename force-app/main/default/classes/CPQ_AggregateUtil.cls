public class CPQ_AggregateUtil {
    
    public static Decimal sumFieldForRecords(List<sObject> objects, Schema.SObjectField field){
        Decimal result = 0;

        if(objects != null){
            for(sObject o : objects){
                if(o != null){
                    Decimal value = (Decimal)o.get(field.getDescribe().getName());
                    if(value != null){
                        result += value;
                    }
                }
            }
        }

        return result;
    }

    public static List<Id> getFieldOfTypeIdForRecords(List<sObject> objects, Schema.SObjectField field){
        List<Id> output = new List<Id>();

        if(objects != null){
            for(sObject o : objects){
                if(o != null){
                    output.add((Id)o.get(field.getDescribe().getName()));
                }
            }
        }

        return output;
    }

    public static Decimal convertToZeroIfNull(Decimal input){
        if(input == null)
            return 0;
        return input;
    }
}