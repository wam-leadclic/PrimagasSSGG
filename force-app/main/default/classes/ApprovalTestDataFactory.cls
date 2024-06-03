@isTest
public class ApprovalTestDataFactory {

    private static final String RESOURCE_NAME_PRODUCTS = 'TEST_Products';

    public static final String OPPORTUNITY_STAGE_DEFAULT = 'Identificada';
    public static final String TANK_NAME_DEFAULT = 'CoolTank';
    public static final String COUNTY_DEFAULT = 'Barcelona';
    public static final String DIMENSION_1_DEFAULT = '10-BULK';
    public static final String DIMENSION_3_DEFAULT = '1000-DU';
    public static final Boolean IS_TANK_OWNER_DEFAULT = false;
    public static final String CODE_EQUIPMENT_DEFAULT = 'EQUIPOCONTADOR';
    public static final String CODE_SERVICE_COST_DEFAULT = 'MANTINTERIORES';
    public static final String CODE_GAS_RATE_DEFAULT = 'SPOT';
    public static final Integer ESTIMATED_CONSUMPTION_DEFAULT = 5000;
    public static final Integer CONTRACT_DURATION_DEFAULT = 5;

    public static Map<String, Product2> products {
        get {
            if (products == null) {
                products = new Map<String, Product2>();
                for (Product2 product : ApprovalTestDataFactory.loadProductData()) {
                    products.put(product.ProductCode, product);
                }
                insert ApprovalTestDataFactory.createPricebookEntries(products.values());        
            }
            return products;
        }
        set;
    }

    public static void createSampleMasterData() {
        TankMasterData__c tankMasterData = new TankMasterData__c(
            Name = TANK_NAME_DEFAULT, 
            Capacity__c = 15000,
            IsAerial__c = true,
            Cost__c = 3500,
            CivilWorks__c = 1200,
            Dismantle__c = 1251,
            EarlyTermination__c = 1200,
            Fencing__c = 700,
            Installation__c = 1600,
            ProjectMemory__c = 300,
            Transport__c = 500
        );
        insert tankMasterData;
        EquipmentMasterData__c equipmentMasterData = new EquipmentMasterData__c(
            Name = 'Sample Equipment',
            Cost__c = 1180,
            Installation__c = 300,
            IsIndoor__c = true,
            SBQQProductCode__c = CODE_EQUIPMENT_DEFAULT
        );
        insert equipmentMasterData;
        insert new TankLegalizationCost__c(
            Cost__c = 600,
            Tank__c = tankMasterData.Id,
            County__c = COUNTY_DEFAULT
        );
        insert new TankMaintenanceCost__c(
            Cost__c = 700,
            Tank__c = tankMasterData.Id,
            County__c = COUNTY_DEFAULT
        );
        insert new GasCost__c(
            Cost__c = 0.377,
            TransportationCost__c = 0.036,
            County__c = COUNTY_DEFAULT
        );
        insert new ServiceCost__c(
            ProfessionalCost__c = 300,
            DomesticCost__c = 150,
            County__c = COUNTY_DEFAULT,
            Service__c = products.get(CODE_SERVICE_COST_DEFAULT).Id
        );
        insert new GPCAPEXRatio__c(
            CountyAverage__c = 63,
            County__c = COUNTY_DEFAULT
        );
        insert new RateAssignation__c(
            Dimension1__c = DIMENSION_1_DEFAULT,
            Dimension3__c = DIMENSION_3_DEFAULT,
            IsTankOwner__c = IS_TANK_OWNER_DEFAULT,
            County__c = COUNTY_DEFAULT,
            Product__c = products.get(CODE_GAS_RATE_DEFAULT).Id
        );
        insert new GasPriceRange__c(
            Range__c = 0.477,
            County__c = COUNTY_DEFAULT
        );
    }

    public static List<Product2> loadProductData() {
        return (List<Product2>) Test.loadData(Product2.sObjectType, RESOURCE_NAME_PRODUCTS);
    }

    public static List<PricebookEntry> createPricebookEntries(List<Product2> products) {
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 product : products) {
            pricebookEntries.add(new PricebookEntry(
                Product2Id = product.Id,
                IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 100 * Math.random()
            ));
        }
        return pricebookEntries;
    }

    public static SObject createSObject(String sObjectName, Map<String, Object> fieldValuePairs) {
        SObject newSObject = Schema.getGlobalDescribe().get(sObjectName).newSObject();
        setFieldValuePairs(newSObject, fieldValuePairs);
        return newSObject;
    }

    private static void setFieldValuePairs(SObject newSObject, Map<String, Object> optionalFieldValues) {
        if (optionalFieldValues != null && !optionalFieldValues.isEmpty()) {
            for (String fieldName : optionalFieldValues.keySet()) {
                newSObject.put(fieldName, optionalFieldValues.get(fieldName));
            }
        }
    }

    public static Account createAccount(Map<String, Object> optionalFieldValues) {
        Account account = new Account (
            Name = 'Leadclic ' + (Math.random() * 100)            
        );
        setFieldValuePairs(account, optionalFieldValues);
        return account;
    }

    public static Opportunity createOpportunity(Id accountId, Map<String, Object> optionalFieldValues) {
        Opportunity opportunity = new Opportunity(
            AccountId = accountId,
            CloseDate = System.today().addDays(30),
            StageName = OPPORTUNITY_STAGE_DEFAULT,
            Name = 'Test Opportunity ' + (Math.random() * 100),
            Dimension1__c = DIMENSION_1_DEFAULT,
            Dimension3__c = DIMENSION_3_DEFAULT,
            Cliente_propietario_del_tanque__c = IS_TANK_OWNER_DEFAULT,
            County__c = COUNTY_DEFAULT
        );
        setFieldValuePairs(opportunity, optionalFieldValues);
        return opportunity;
    }

    public static SBQQ__Quote__c createQuote(Id opportunityId, Map<String, Object> optionalFieldValues) {
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = opportunityId,
            EstimatedConsumption__c = ESTIMATED_CONSUMPTION_DEFAULT,
            Duration__c = CONTRACT_DURATION_DEFAULT,
            ClientTank__c = IS_TANK_OWNER_DEFAULT
        );
        setFieldValuePairs(quote, optionalFieldValues);
        return quote;
    }
}