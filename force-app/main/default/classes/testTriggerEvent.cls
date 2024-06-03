/**
Test para testear el trigger de eventos
Ponemos SeeAllData para que se pueda acceder a las etiquetas personalizadas
 */
@isTest(SeeAllData = true)
private class testTriggerEvent {

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
        candidato2.N_mero_Cliente_Anterior__c = 1112;
        insert candidato2;
        
        list<Event> lEventos = new list<Event> ();
        Event evento = new Event();
        evento.Subject = 'Reunión';
        evento.WhoId = candidato.Id;
        evento.StartDateTime = system.now()+1;
        evento.EndDateTime = system.now()+1;
        evento.OwnerId = prop;
        lEventos.add(evento);
        
        Event evento2 = new Event();
        evento2.Subject = 'Reunión';
        evento2.WhoId = candidato2.Id;
        evento2.StartDateTime = system.now()+2;
        evento2.EndDateTime = system.now()+2;
        evento2.OwnerId = prop;
        lEventos.add(evento2);
        
        Event evento3 = new Event();
        evento3.Subject = 'Reunión';
        evento3.WhoId = candidato2.Id;
        evento3.StartDateTime = system.now()+1;
        evento3.EndDateTime = system.now()+1;
        evento3.OwnerId = prop;
        lEventos.add(evento3);
         
        test.startTest();
        	insert lEventos;
        	update lEventos;
        test.stopTest();
    }
}