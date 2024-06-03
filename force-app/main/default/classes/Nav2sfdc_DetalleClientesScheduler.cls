global class Nav2sfdc_DetalleClientesScheduler implements Schedulable 
{
	public Integer numReintentos = 0;

	public Nav2sfdc_DetalleClientesScheduler(){}

	public Nav2sfdc_DetalleClientesScheduler(Integer numReintentos) 
	{
		this.numReintentos = numReintentos;
	}

	global void execute(SchedulableContext sc) 
	{
		System.enqueueJob(new Nav2sfdc_ActualizacionDiariaClientes(numReintentos));

		//Para que no se quede un trabajo como programado, paramos el de timeout una vez se ha vuelto a encolar
        Map<String,String> mapaIdDetailsIdJob = new Map<String,String>();

		for(CronTrigger cronTr : [SELECT CronJobDetailId, id, CronExpression, TimesTriggered, NextFireTime, State FROM CronTrigger WHERE NextFireTime = null])
        {
            mapaIdDetailsIdJob.put(cronTr.CronJobDetailId,cronTr.Id);
        }
        
        List<CronJobDetail> listaJobDetails = [select Name, Id from CronJobDetail where Id in: mapaIdDetailsIdJob.keySet()];
        for(CronJobDetail jobDetail : listaJobDetails)
        {
        	if(jobDetail.Name.equals('Nav2sfdc_DetalleClientesScheduler_Timeout'))
        	{
        		System.abortJob(mapaIdDetailsIdJob.get(jobDetail.Id));
        	}
        } 
	}
}