@isTest
public without sharing class CPQ_TestDataFactory {

    public static void LoadAllCSVTestDatasets(){
        LoadGasCosts();
        LoadProducts();
        LoadEquipmentMasterData();
        LoadTankMasterData();
        LoadTankMaintenanceCosts();
        LoadServiceCosts();
    }
    
    public static void LoadGasCosts(){
        Test.loadData(GasCost__c.sObjectType, 'CPQ_TEST_GasCostsCSV');
    }
    public static void LoadProducts(){
        Test.loadData(Product2.sObjectType, 'CPQ_TEST_ProductsCSV');
    }
    public static void LoadTankMaintenanceCosts(){
        Test.loadData(TankMaintenanceCost__c.sObjectType, 'CPQ_TEST_TankMaintenanceCostCSV');
    }
    public static void LoadTankMasterData(){
        Test.loadData(TankMasterData__c.sObjectType, 'CPQ_TEST_TankMasterDataCSV');
    }
    public static void LoadServiceCosts(){
        Test.loadData(ServiceCost__c.sObjectType, 'CPQ_TEST_ServiceCostsCSV');
    }
    public static void LoadEquipmentMasterData(){
        Test.loadData(EquipmentMasterData__c.sObjectType, 'CPQ_TEST_EquipmentMasterDataCSV');
    }
    public static void setDefaultSettings(){
        CPQ_Settings.setTestSetting(new CPQ_Settings__mdt(DiscountRatePercentage__c = 11,
                                                            DepRate5Years__c = 11,
                                                            DepRate10Years__c = 6,
                                                            DepYears__c = 15,
                                                            DefaultPBAEstimatedConsPerc__c = 80,
                                                            LogsEnabled__c = false));
    }

    public static void buildTestQuoteA(Id accountId){

        Opportunity opp1 = new CPQ_TestDataFactory.OpportunityBuilder('Opp1')
            .withCounty('Barcelona')
            .withCloseDate(Date.today())
            .withDimension3(CPQ_Opportunity.DIMENSION3_1000_DU)
            .withStageName('Closed')
            .build();
        insert opp1;

        SBQQ__Quote__c quote1 = new CPQ_TestDataFactory.QuoteBuilder()
            .withOpportunity(opp1.Id)
            .withContractDuration(5)
            .withAccount(accountId)
            .withEstimatedConsumption(10000)
            .build();
        insert quote1;

        List<SBQQ__QuoteLine__c> qlis = new List<SBQQ__QuoteLine__c>{
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.DEPOSITO).Id)
                .withNetPrice(2250)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.TRANSDEPOSITO).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.LEGALIZACION).Id)
                .withNetPrice(225)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.INSTALACION).Id)
                .withNetPrice(1100)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.PROYECTOMEMORIA).Id)
                .withNetPrice(300)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.OBRACIVIL).Id)
                .withNetPrice(750)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.VALLADO).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),

            // OTHER EQUIPMENT 
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode('CALDERA36KW').Id)
                .withNetPrice(3000)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.INSTALACION).Id)
                .withNetPrice(500)
                .withQuantity(1)
                .build(),

            // PRIMASERVICIOS 
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.PRIMASERVICIOS).Id)
                .withNetPrice(9.95)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.PUESTAAPUNTO).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.MANTDEPOSITO).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.ATENCION24).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.SEGURO).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.INSPOBLIGATORIA).Id)
                .withNetPrice(2.95)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.MANTINTERIORES).Id)
                .withNetPrice(6.95)
                .withQuantity(1)
                .build(),
                
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.CUOTASINVERSION).Id)
                .withNetPrice(30)
                .withQuantity(15)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.PAGOINICIAL).Id)
                .withNetPrice(400)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.DESC1LLENADO).Id)
                .withNetPrice(500)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.CUOTASALQUILER).Id)
                .withNetPrice(20)
                .withQuantity(24)
                .build(),
            // RATE
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.TARIFA).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.SPOT).Id)
                .withNetPrice(0.79)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.DESCTARIFA).Id)
                .withNetPrice(0.05)
                .withDiscountDuration(3)
                .build()
        };

        insert qlis;
    }

    public static void buildTestQuoteB(Id accountId){

        Opportunity opp1 = new CPQ_TestDataFactory.OpportunityBuilder('Opp2')
            .withCounty('Barcelona')
            .withCloseDate(Date.today())
            .withDimension3(CPQ_Opportunity.DIMENSION3_1000_DU)
            .withStageName('Closed')
            .build();
        insert opp1;

        SBQQ__Quote__c quote1 = new CPQ_TestDataFactory.QuoteBuilder()
            .withOpportunity(opp1.Id)
            .withContractDuration(5)
            .withAccount(accountId)
            .withEstimatedConsumption(10000)
            .build();
        insert quote1;

        List<SBQQ__QuoteLine__c> qlis = new List<SBQQ__QuoteLine__c>{
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.DEPOSITO).Id)
                .withNetPrice(2250)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.TRANSDEPOSITO).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.LEGALIZACION).Id)
                .withNetPrice(225)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.INSTALACION).Id)
                .withNetPrice(1100)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.PROYECTOMEMORIA).Id)
                .withNetPrice(300)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.OBRACIVIL).Id)
                .withNetPrice(750)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.VALLADO).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .withTankName('ETERNELLA')
                .build(),

            // OTHER EQUIPMENT 
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode('CALDERA36KW').Id)
                .withNetPrice(3000)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.INSTALACION).Id)
                .withNetPrice(500)
                .withQuantity(1)
                .build(),

            // PRIMASERVICIOS 
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.PRIMASERVICIOS).Id)
                .withNetPrice(9.95)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.PUESTAAPUNTO).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.MANTDEPOSITO).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.ATENCION24).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.SEGURO).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.INSPOBLIGATORIA).Id)
                .withNetPrice(2.95)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.MANTINTERIORES).Id)
                .withNetPrice(6.95)
                .withQuantity(1)
                .build(),
                
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.CUOTASINVERSION).Id)
                .withNetPrice(30)
                .withQuantity(15)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.PAGOINICIAL).Id)
                .withNetPrice(400)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.DESC1LLENADO).Id)
                .withNetPrice(500)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.CUOTASALQUILER).Id)
                .withNetPrice(20)
                .withQuantity(24)
                .build(),
            // RATE
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.TARIFA).Id)
                .withNetPrice(0)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.SPOT).Id)
                .withNetPrice(0.79)
                .withQuantity(1)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.DESCTARIFA).Id)
                .withNetPrice(0.05)
                .withDiscountDuration(3)
                .build(),
            new CPQ_TestDataFactory.QuoteLineItemBuilder(quote1.Id)
                .withProduct(CPQ_TestDataFactory.getProductByCode(CPQ_ProductCodes.VAPORIZADOR).Id)
                .withNetPrice(800)
                .withQuantity(1)
                .build()
        };

        insert qlis;
    }

    private static Map<String, Product2> productsByProductCode = new Map<String, Product2>();
    private static Map<String, TankMaintenanceCost__c> tankMaintenanceCostByName = new Map<String, TankMaintenanceCost__c>();
    private static Map<String, TankMasterData__c> tankMasterDataByName = new Map<String, TankMasterData__c>();

    public static void FetchProductsByProductCode(){
        for(Product2 p : [SELECT Id, ProductCode FROM Product2 WHERE IsActive = true]){
            productsByProductCode.put(p.ProductCode, p);
        }
    }
    public static void FetchTankMaintenanceCostByTankName(){
        for(TankMaintenanceCost__c t : [SELECT Id, Name, Cost__c FROM TankMaintenanceCost__c]){
            tankMaintenanceCostByName.put(t.Name, t);
        }
    }
    public static void FetchTankMasterDataByTankName(){
        for(TankMasterData__c t : [SELECT Id, Name, Cost__c FROM TankMasterData__c]){
            tankMasterDataByName.put(t.Name, t);
        }
    }

    public static Product2 getProductByCode(String code){
        return productsByProductCode.get(code);
    }

    public class AccountBuilder {
        private Account obj = new Account();

        public AccountBuilder(String name){
            obj.Name = name;
        }

        public Account build() {
            return obj;
        }
    }

    public class OpportunityBuilder {
        private Opportunity obj = new Opportunity();

        public OpportunityBuilder(String name){
            obj.Name = name;
        }

        public OpportunityBuilder withCounty(String value) {
            obj.County__c = value;
            return this;
        }
        public OpportunityBuilder withStageName(String value) {
            obj.StageName = value;
            return this;
        }
        public OpportunityBuilder withCloseDate(Date value) {
            obj.CloseDate = value;
            return this;
        }
        public OpportunityBuilder withDimension3(String value) {
            obj.Dimension3__c = value;
            return this;
        }

        public Opportunity build() {
            return obj;
        }
    }


    public class QuoteBuilder {
        private SBQQ__Quote__c obj = new SBQQ__Quote__c();

        public QuoteBuilder withAccount(Id value) {
            obj.SBQQ__Account__c = value;
            return this;
        }
        
        public QuoteBuilder withContractDuration(Decimal value) {
            obj.Duration__c = value;
            return this;
        }

        public QuoteBuilder withEstimatedConsumption(Decimal value) {
            obj.EstimatedConsumption__c = value;
            return this;
        }

        public QuoteBuilder withOpportunity(Id value) {
            obj.SBQQ__Opportunity2__c = value;
            return this;
        }

        public QuoteBuilder withStatus(String value) {
            obj.SBQQ__Status__c = value;
            return this;
        }

        public QuoteBuilder withClientTank(Boolean value) {
            obj.ClientTank__c = value;
            return this;
        }
        public QuoteBuilder withHasStretches(Boolean value) {
            obj.HasStretches__c = value;
            return this;
        }

        public SBQQ__Quote__c build() {
            return obj;
        }
    }

    public class QuoteLineItemBuilder {
        private SBQQ__QuoteLine__c obj = new SBQQ__QuoteLine__c();

        public QuoteLineItemBuilder(Id quoteId){
            obj.SBQQ__Quote__c = quoteId;
        }

        public QuoteLineItemBuilder withProduct(Id value) {
            obj.SBQQ__Product__c = value;
            return this;
        }
        public QuoteLineItemBuilder withNetPrice(Decimal value) {
            obj.SBQQ__NetPrice__c = value;
            return this;
        }
        public QuoteLineItemBuilder withQuantity(Decimal value) {
            obj.SBQQ__Quantity__c = value;
            return this;
        }
        public QuoteLineItemBuilder withDiscountDuration(Decimal value) {
            obj.DiscountDuration__c = value;
            return this;
        }
        public QuoteLineItemBuilder withTankName(String value) {
            obj.TankName__c = value;
            return this;
        }
        public SBQQ__QuoteLine__c build() {
            return obj;
        }
    }


}