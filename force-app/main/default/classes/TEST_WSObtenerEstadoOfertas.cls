@isTest
private class TEST_WSObtenerEstadoOfertas 
{
	@isTest static void peticionConDatosIncorrectos() 
	{
		WSObtenerEstadoOfertas.PeticionOfertas peticion = new WSObtenerEstadoOfertas.PeticionOfertas();
		peticion.ofertas = null;

		Test.startTest();
		String jDatos = WSObtenerEstadoOfertas.getEstadosOfertas(peticion);
		Test.stopTest();

		WSObtenerEstadoOfertas.Respuesta r = (WSObtenerEstadoOfertas.Respuesta) JSON.deserialize(jDatos, WSObtenerEstadoOfertas.Respuesta.class);

		System.debug('Respuesta: ' + r);

		System.assertEquals('601', r.resultado.codigo);
	}

	@isTest static void noExisteOferta() 
	{
		WSObtenerEstadoOfertas.PeticionOfertas peticion = new WSObtenerEstadoOfertas.PeticionOfertas();
		peticion.ofertas = new List<WSObtenerEstadoOfertas.OfertaId>();
		WSObtenerEstadoOfertas.OfertaId ofId = new WSObtenerEstadoOfertas.OfertaId();
		ofId.identificador = '0Q0D0000LL0KQrRKAW';
		peticion.ofertas.add(ofId);

		//String jOferta = JSON.serialize(peticion);
		//System.debug('jOferta: ' + jOferta);

		Test.startTest();
		String jDatos = WSObtenerEstadoOfertas.getEstadosOfertas(peticion);
		Test.stopTest();

		WSObtenerEstadoOfertas.Respuesta r = (WSObtenerEstadoOfertas.Respuesta) JSON.deserialize(jDatos, WSObtenerEstadoOfertas.Respuesta.class);

		System.debug('Respuesta: ' + r);

		System.assertEquals('603', r.resultado.codigo);
	}

	@isTest static void siExisteOferta() 
	{
		// crear la oportunidad
		Opportunity op = new Opportunity();
		op.Name = 'OpTest';
		op.StageName = 'Identificada';
		op.CloseDate = Date.today();
		insert op;

		// crear la oferta
		Quote quo = new Quote();
		quo.Name = 'OfertaTest';
		quo.Status = 'Preparando';
		quo.OpportunityId = op.Id;
		insert quo;

		String id = quo.Id;

		WSObtenerEstadoOfertas.PeticionOfertas peticion = new WSObtenerEstadoOfertas.PeticionOfertas();
		peticion.ofertas = new List<WSObtenerEstadoOfertas.OfertaId>();
		WSObtenerEstadoOfertas.OfertaId ofId = new WSObtenerEstadoOfertas.OfertaId();
		ofId.identificador = id;
		peticion.ofertas.add(ofId);

		//String jOferta = JSON.serialize(peticion);
		//System.debug('jOferta: ' + jOferta);

		Test.startTest();
		String jDatos = WSObtenerEstadoOfertas.getEstadosOfertas(peticion);
		Test.stopTest();

		WSObtenerEstadoOfertas.Respuesta r = (WSObtenerEstadoOfertas.Respuesta) JSON.deserialize(jDatos, WSObtenerEstadoOfertas.Respuesta.class);

		System.debug('Respuesta: ' + r);

		System.assertEquals('600', r.resultado.codigo);
		System.assertNotEquals(null, r.ofertas);
		System.assert(r.ofertas.size() > 0);
		System.assertNotEquals(null, r.ofertas.get(0));
		System.assertEquals('Preparando', r.ofertas.get(0).estado);
	}
}