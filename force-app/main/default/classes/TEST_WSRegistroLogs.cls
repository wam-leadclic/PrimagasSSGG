@isTest
private class TEST_WSRegistroLogs
{	
	@isTest static void peticionRegistrarLogsVacio() 
	{
		WSRegistroLogs.PeticionLogs peticion = new WSRegistroLogs.PeticionLogs();

		Test.startTest();
		String jDatos = WSRegistroLogs.registrarLogs(peticion);
		Test.stopTest();
        
        WSRegistroLogs.Respuesta r = (WSRegistroLogs.Respuesta) JSON.deserialize(jDatos, WSRegistroLogs.Respuesta.class);

		System.debug('Respuesta: ' + r);

		System.assertEquals('201', r.resultado.codigo);
        System.assertEquals(label.WSError_201, r.resultado.texto);
	}

	@isTest static void peticionRegistrarLogsCorrecto() 
	{
		WSRegistroLogs.PeticionLogs peticion = new WSRegistroLogs.PeticionLogs();
        
        peticion.logs = new List<WSRegistroLogs.Log>();
        
        WSRegistroLogs.log log = new WSRegistroLogs.Log();
        log.clase = 'TEST_Clase';
        log.descripcion = 'TEST_Descripcion';
        log.esError = 'false';
        log.identificador = 'TEST_Identificador';
        log.metodo = 'TEST_metodo';
        
        peticion.logs.add(log);

		Test.startTest();
		String jDatos = WSRegistroLogs.registrarLogs(peticion);
		Test.stopTest();
        
        WSRegistroLogs.Respuesta r = (WSRegistroLogs.Respuesta) JSON.deserialize(jDatos, WSRegistroLogs.Respuesta.class);

		System.debug('Respuesta: ' + r);
	
        System.assertEquals('200', r.resultado.codigo);
        System.assertEquals(label.WSError_200_1, r.resultado.texto);
		
	}
    
    @isTest static void peticionRegistrarLogsCorrectoFaltanCampos() 
	{
		WSRegistroLogs.PeticionLogs peticion = new WSRegistroLogs.PeticionLogs();
        
        peticion.logs = new List<WSRegistroLogs.Log>();
        
        WSRegistroLogs.log log = new WSRegistroLogs.Log();
        log.descripcion = 'TEST_Descripcion';
        log.clase = 'TEST_Clase';
        log.esError = 'false';
        log.identificador = 'TEST_Identificador';
        log.metodo = 'TEST_metodo';
        
        WSRegistroLogs.log log2 = new WSRegistroLogs.Log();
        log2.descripcion = 'TEST_Descripcion2';
        log2.esError = 'false';
        log2.identificador = 'TEST_Identificador2';
        log2.metodo = 'TEST_metodo2';
        
        peticion.logs.add(log);
        peticion.logs.add(log2);

		Test.startTest();
		String jDatos = WSRegistroLogs.registrarLogs(peticion);
		Test.stopTest();
        
        WSRegistroLogs.Respuesta r = (WSRegistroLogs.Respuesta) JSON.deserialize(jDatos, WSRegistroLogs.Respuesta.class);

		System.debug('Respuesta: ' + r);

		System.assertEquals('200', r.resultado.codigo);
        System.assertEquals('1 log insertado correctamente. Ha fallado 1 log al insertarse porque le falta algún campo. Id del log que ha fallado: TEST_Identificador2', r.resultado.texto);

	}
}