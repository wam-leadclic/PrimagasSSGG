/* 
Trigger encargado de que cuando se inserta, modifica una tarea si el candidato es propiedad de un Comercial
se actualizará el campo Fecha_Actividad_Asignacion__c con la primera actividad que se haya completado
FECHA		AUTOR		DESCRIPCIÓN
06/02/14	RMG			Creación.
*/

trigger triggerTask on Task (after insert, after update) {
	//lista con los candidatos relacionados con las tareas
	list<string> lIdCandidatos = new list<string>();
	
	//lista con las tareas insertadas, modificadas o eliminadas
	list<Task> lTareas = new list<Task>();
	if(trigger.isInsert || trigger.isUpdate){
		lTareas = trigger.new;
	}
	
	//Recogemos las tareas asociadas a los candidatos
	for(Task tarea :lTareas){
		//Si la tarea esta relacionado con una cuenta o candidato
		if(tarea.whoId != null){
			//Si el id empieza por '00Q' está relacionado con un candidato
			if(string.valueOf(tarea.whoId).substring(0,3) == '00Q' ){
				lIdCandidatos.add(tarea.whoId);
			}
		}	
	}
	
	map<string, Lead> mCandidatos = new map<string, Lead> ();
	//Si la lista de id de candidatos no están vacios
	if(!lIdCandidatos.isEmpty()){
		//Buscamos los candidatos 
		mCandidatos = new map<string, Lead> ([SELECT Id, OwnerId, Owner.ProfileId, Fecha_Asignado_Comercial__c, Fecha_Actividad_Asignacion__c FROM Lead where id in :lIdCandidatos]);
	}
	
	map<id, Lead> mCandModificar = new map<id, Lead> ();
	//Recorremos las tareas que han sido modificadas, eliminadas o insertadas 
	for(Task tarea :lTareas){
		if(tarea.whoId != null){
			//Si el id empieza por '00Q' está relacionado con un candidato
			if(string.valueOf(tarea.whoId).substring(0,3) == '00Q' && tarea.status == system.label.Completada){
				Lead cand = mCandidatos.get(tarea.whoId);
				//El propietario del candidato tiene que ser un comercial y el propietario de la tarea tiene que ser el propietario del candidato
				if(cand.Owner.ProfileId == system.label.PerfilComercial && cand.OwnerId == tarea.OwnerId && cand.Fecha_Asignado_Comercial__c != null){
					//Se modifica la fecha si es la primera actividad que completa desde que la tarea a sido asignada a un comercial y la fecha de fin evento es mayor o igual que la fecha de asignación del candidato
					if(cand.Fecha_Actividad_Asignacion__c == null && tarea.Fecha_fin_tarea__c >= cand.Fecha_Asignado_Comercial__c.date()){
						cand.Fecha_Actividad_Asignacion__c = tarea.Fecha_fin_tarea__c;
						mCandModificar.put(tarea.whoId, cand);
					}else{
						//Si no está en el mapa lo añadimos
						if(!mCandModificar.containsKey(tarea.whoId)){
							//si la fecha es menor que la de asignación que ya tiene el candidato
							if((cand.Fecha_Actividad_Asignacion__c != null) && (tarea.Fecha_fin_tarea__c < cand.Fecha_Actividad_Asignacion__c) && tarea.Fecha_fin_tarea__c >= cand.Fecha_Asignado_Comercial__c.date()){
								cand.Fecha_Actividad_Asignacion__c = tarea.Fecha_fin_tarea__c;
								mCandModificar.put(tarea.whoId, cand);
							}
						}else{
							//si la fecha es menor que la de asignacion que ya tiene el candidato y la fecha que está ya en el mapa
							if(((cand.Fecha_Actividad_Asignacion__c != null)) && (tarea.Fecha_fin_tarea__c < cand.Fecha_Actividad_Asignacion__c) && (tarea.Fecha_fin_tarea__c < mCandModificar.get(tarea.whoId).Fecha_Actividad_Asignacion__c) && tarea.Fecha_fin_tarea__c >= cand.Fecha_Asignado_Comercial__c.date()){
								cand.Fecha_Actividad_Asignacion__c = tarea.Fecha_fin_tarea__c;
								mCandModificar.put(tarea.whoId, cand);
							}
						}
					}
				}
			}
		}
	}
	
	update mCandModificar.values();
}