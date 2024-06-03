@isTest
private class TEST_WSVersionesNewSales
{
    @isTest static void peticionComprobarVersionConDatosIncorrectos() 
    {
        WSVersionesNewSales.PeticionVersiones peticion = new WSVersionesNewSales.PeticionVersiones();
        peticion.version = null;

        Test.startTest();
        String jDatos = WSVersionesNewSales.comprobarVersion(peticion);
        Test.stopTest();

        WSVersionesNewSales.Respuesta r = (WSVersionesNewSales.Respuesta) JSON.deserialize(jDatos, WSVersionesNewSales.Respuesta.class);

        System.debug('Respuesta: ' + r);

        System.assertEquals('901', r.resultado.codigo); 
        System.assertEquals(Label.WSError_901, r.resultado.texto);
    }

    @isTest static void peticionComprobarVersionConDatosCorrectosSinCustomSettings() 
    {
        WSVersionesNewSales.PeticionVersiones peticion = new WSVersionesNewSales.PeticionVersiones();
        peticion.version = '1.0';
        peticion.usuario = 'usuario';

        Test.startTest();
        String jDatos = WSVersionesNewSales.comprobarVersion(peticion);
        Test.stopTest();

        WSVersionesNewSales.Respuesta r = (WSVersionesNewSales.Respuesta) JSON.deserialize(jDatos, WSVersionesNewSales.Respuesta.class);

        System.debug('Respuesta: ' + r);

        System.assertEquals('903', r.resultado.codigo); 
        System.assertEquals(Label.WSError_903, r.resultado.texto);
    }

    @isTest static void peticionComprobarVersionConDatosCorrectosVersionUltima() 
    {
        WSVersionesNewSales.PeticionVersiones peticion = new WSVersionesNewSales.PeticionVersiones();
        peticion.version = '2.0';
        peticion.usuario = 'usuario';

        ConfiguracionBase_NewSales__c versionAnterior = new ConfiguracionBase_NewSales__c();
        versionAnterior.Name = WSVersionesNewSales.VERSION_ANTERIOR;
        versionAnterior.Valor__c = '1.0';
        insert versionAnterior;

        ConfiguracionBase_NewSales__c versionUltima = new ConfiguracionBase_NewSales__c();
        versionUltima.Name = WSVersionesNewSales.VERSION_ULTIMA;
        versionUltima.Valor__c = '2.0';
        insert versionUltima;

        Test.startTest();
        String jDatos = WSVersionesNewSales.comprobarVersion(peticion);
        Test.stopTest();

        WSVersionesNewSales.Respuesta r = (WSVersionesNewSales.Respuesta) JSON.deserialize(jDatos, WSVersionesNewSales.Respuesta.class);

        System.debug('Respuesta: ' + r);

        System.assertEquals('900', r.resultado.codigo);
        System.assertEquals(Label.WSError_900, r.resultado.texto);
    }

     @isTest static void peticionComprobarVersionConDatosCorrectosVersionAnterior() 
    {
        WSVersionesNewSales.PeticionVersiones peticion = new WSVersionesNewSales.PeticionVersiones();
        peticion.version = '1.101';
        peticion.usuario = 'usuario';

        ConfiguracionBase_NewSales__c versionAnterior = new ConfiguracionBase_NewSales__c();
        versionAnterior.Name = WSVersionesNewSales.VERSION_ANTERIOR;
        versionAnterior.Valor__c = '1.0';
        insert versionAnterior;

        ConfiguracionBase_NewSales__c versionUltima = new ConfiguracionBase_NewSales__c();
        versionUltima.Name = WSVersionesNewSales.VERSION_ULTIMA;
        versionUltima.Valor__c = '2.0';
        insert versionUltima;

        Test.startTest();
        String jDatos = WSVersionesNewSales.comprobarVersion(peticion);
        Test.stopTest();

        WSVersionesNewSales.Respuesta r = (WSVersionesNewSales.Respuesta) JSON.deserialize(jDatos, WSVersionesNewSales.Respuesta.class);

        System.debug('Respuesta: ' + r);

        System.assertEquals('904', r.resultado.codigo);
        System.assertEquals(Label.WSError_904, r.resultado.texto);
    }

    @isTest static void peticionComprobarVersionConDatosCorrectosVersionObsoleta() 
    {
        WSVersionesNewSales.PeticionVersiones peticion = new WSVersionesNewSales.PeticionVersiones();
        peticion.version = '0.0';
        peticion.usuario = 'usuario';

        ConfiguracionBase_NewSales__c versionAnterior = new ConfiguracionBase_NewSales__c();
        versionAnterior.Name = WSVersionesNewSales.VERSION_ANTERIOR;
        versionAnterior.Valor__c = '1.0';
        insert versionAnterior;

        ConfiguracionBase_NewSales__c versionUltima = new ConfiguracionBase_NewSales__c();
        versionUltima.Name = WSVersionesNewSales.VERSION_ULTIMA;
        versionUltima.Valor__c = '2.0';
        insert versionUltima;

        Test.startTest();
        String jDatos = WSVersionesNewSales.comprobarVersion(peticion);
        Test.stopTest();

        WSVersionesNewSales.Respuesta r = (WSVersionesNewSales.Respuesta) JSON.deserialize(jDatos, WSVersionesNewSales.Respuesta.class);

        System.debug('Respuesta: ' + r);

        System.assertEquals('905', r.resultado.codigo);
        System.assertEquals(Label.WSError_905, r.resultado.texto);
    }
}