@isTest
private class TEST_Util 
{   
    public static Integer NUM_ACCOUNTS = 1;

    //Cubre el lanzamiento de excepciones personalizadas
    @isTest 
    static void test_customException() 
    {
        try
        {
            throw new Util.customException('Test');
        }catch(Exception e)
        {
            System.assertEquals(e.getMessage(), 'Test');
        }
    }

    /*La generacion del hash está cubierta por los triggers de Lead, Account y Contact ya que se encargan de llamar a ese metodo*/
}