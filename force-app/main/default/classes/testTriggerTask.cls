/**
Test para testear el trigger de tareas
Ponemos SeeAllData para que se pueda acceder a las etiquetas personalizadas
 */
@isTest(SeeAllData = true)
private class testTriggerTask {

    static testMethod void myUnitTest() {
    	Id prop = [Select Id from User where IsActive = true and ProfileId = :system.label.PerfilComercial LIMIT 1].get(0).id;
        Lead candidato = new Lead();
        candidato.lastName = 'test';
        candidato.OwnerId = prop;
        candidato.State = 'Prueba';
        candidato.C_digo_Postal__c = '28004';
        candidato.LeadSource = 'web';
        candidato.Contact_State__c = 'Prueba';
        candidato.Fecha_Asignado_Comercial__c = system.now();
        candidato.N_mero_Cliente_Anterior__c = 1111;
        insert candidato;
        
        Lead candidato2 = new Lead();
        candidato2.lastName = 'test';
        candidato2.OwnerId = prop;
        candidato2.State = 'Prueba';
        candidato2.C_digo_Postal__c = '28004';
        candidato2.LeadSource = 'web';
        candidato2.Contact_State__c = 'Prueba';
        candidato2.Fecha_Actividad_Asignacion__c = system.today()+5;
        candidato2.Fecha_Asignado_Comercial__c = system.now();
        candidato2.N_mero_Cliente_Anterior__c = 1112;
        insert candidato2;
        
        
        list<Task> lTareas = new list<Task> ();
        Task tarea = new Task ();
        tarea.subject = 'Llamada';
        tarea.Status = 'Completada';
        tarea.WhoId = candidato.Id;
        tarea.ActivityDate = system.today()+3;
        tarea.Fecha_fin_tarea__c = system.today()+3;
        tarea.OwnerId = prop;
        lTareas.add(tarea);
        
        Task tarea2 = new Task ();
        tarea2.subject = 'Llamada';
        tarea2.Status = 'Completada';
        tarea2.WhoId = candidato2.Id;
        tarea2.ActivityDate = system.today()+4;
        tarea2.Fecha_fin_tarea__c = system.today()+4;
        tarea2.OwnerId = prop;
        lTareas.add(tarea2);
        
        Task tarea3 = new Task ();
        tarea3.subject = 'Llamada';
        tarea3.Status = 'Completada';
        tarea3.WhoId = candidato2.Id;
        tarea3.ActivityDate = system.today()+3;
        tarea3.Fecha_fin_tarea__c = system.today()+3;
        tarea3.OwnerId = prop;
        lTareas.add(tarea3);
         
        test.startTest();
        	insert lTareas;
        test.stopTest();
    }
}