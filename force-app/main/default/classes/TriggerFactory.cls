/**
 * Class TriggerFactory
 *
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
 */
public class TriggerFactory
{
	private class TriggerHandlerException extends Exception {}
	
	/**
	 * Public static method to create and execute a trigger handler
	 *
	 * Arguments:	Schema.sObjectType soType - Object type to process (SObject.sObjectType)
	 *
	 * Throws a TriggerException if no handler has been coded.
	 * @change 05/06/2019 Modificación para hacer uso de un patrón mejorado para controlar los triggers mediante metadatos
	 */
	public static void createHandler(Schema.sObjectType soType)
	{
		Map<String, Configuration_Switch__mdt> configurationSwitchMap = Util.configurationSwitchMap;
		String sObjectName = String.valueOf(soType);

		// Get the Trigger Setup related to the soType
        Configuration_Switch__mdt triggerHandler = configurationSwitchMap.get(sObjectName);

		// Get a handler appropriate to the object being processed
		ITrigger handler = getHandler(triggerHandler, sObjectName);
		
		// Make sure we have a handler registered, new handlers must be registered in the getHandler method.
		if (handler != null)
		{
			// Execute the handler to fulfil the trigger
			execute(handler);
			//throw new TriggerException('No Trigger Handler registered for Object Type: ' + soType);
		}
		
		
	}
	
	/**
	 * private static method to control the execution of the handler
	 *
	 * Arguments:	ITrigger handler - A Trigger Handler to execute
	 */	
	private static void execute(ITrigger handler)
	{
		// Before Trigger
		if (Trigger.isBefore)
		{
			// Call the bulk before to handle any caching of data and enable bulkification
			handler.bulkBefore(trigger.new, trigger.oldMap);
			
			// Iterate through the records to be inserted passing them to the handler.
			if (Trigger.isInsert)
			{
				handler.beforeInsert(trigger.new);
			}
			// Iterate through the records to be updated passing them to the handler.
			else if (Trigger.isUpdate)
			{
				handler.beforeUpdate(trigger.new, trigger.oldMap);
			}
			// Iterate through the records to be deleted passing them to the handler.
			else if (Trigger.isDelete)
			{
				handler.beforeDelete(trigger.oldMap);
			}
		}
		else
		{
			// Call the bulk after to handle any caching of data and enable bulkification
			handler.bulkAfter(trigger.new, trigger.oldMap);
			
			// Iterate through the records inserted passing them to the handler.
			if (Trigger.isInsert)
			{
				handler.afterInsert(trigger.new);
			}
			// Iterate through the records updated passing them to the handler.
			else if (Trigger.isUpdate)
			{
				handler.afterUpdate(trigger.new, trigger.oldMap);
			}
			// Iterate through the records deleted passing them to the handler.
			else if (Trigger.isDelete)
			{
				handler.afterDelete(trigger.oldMap);
			}
		}
		
		// Perform any post processing
		handler.andFinally();
	}
	
	/**
     * Private static method to get the appropriate handler for the object type from the Trigger Setup record
     **
     * @change rcastanos (05/06/2016) Modificación para hacer uso de un patrón mejorado para controlar los triggers mediante metadatos
     * @param triggerHandler - Trigger Handler configured
     * @param sObjectName - Name of the sObject. Used for debuf purposes only
     * @return ITrigger - A trigger handler if one exists or null.
     */
	private static ITrigger getHandler(Configuration_Switch__mdt triggerHandler, String sObjectName)
	{
		if(triggerHandler != null)
        {
            Type handlerClass = null;
            Object handler = null;

            if(triggerHandler.Activo__c)
            {
                handlerClass = Type.forName(triggerHandler.DeveloperName);

                if(handlerClass == null)
                {
                  throw new TriggerHandlerException('Handler either not exists or not properly configured - Be sure the class ' + triggerHandler.DeveloperName + ' exists and is defined as global.');
                }

                handler = handlerClass.newInstance();

                if(handler instanceof ITrigger)
                {
                    return (ITrigger) handler;
                }

                throw new TriggerHandlerException('Handler not properly configured - Be sure the class ' + triggerHandler.DeveloperName + ' implements the ITrigger interface.');
            }

            return null;
        }
        else
        {
            throw new TriggerHandlerException('No Trigger Handler registered for Object Type: ' + sObjectName);
        }
	}
}