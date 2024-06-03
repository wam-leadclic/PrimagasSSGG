public with sharing class CPQ_QuotePageCtrl {
    private static final Decimal CONVERSION_FACTOR_KG_MWH = 71.99;
    public RecordWrapper q { get; set; }
    public Date today {get;set;}
    public Date quoteExpiringDate {get;set;}
    public String userFullName { get{ return UserInfo.getName();} }
    public String userEmail { get{ return UserInfo.getUserEmail();} }
    public String userMobilePhone { get{ return [SELECT MobilePhone FROM User WHERE Username =: UserInfo.getUserName()].MobilePhone;} }

    public CPQ_QuotePageCtrl() {
        today = Date.today();
        quoteExpiringDate = today + 30;
        q = new RecordWrapper(
            CPQ_QuoteService.buildWrapperForPDFQuote(ApexPages.currentPage().getParameters().get('id'))
        );
    }

    public class RecordWrapper {
        public String accountName { get; set; }
        public Date quoteDate { get; set; }
        public String county { get; set; }
        public Map<String, Integer> tanksToInstall { get; set; }
        public Map<String, Integer> otherEquipmentsToInstall { get; set; }

        public String primagasCost { get; set; }
        public String customerCost { get; set; }
        private Decimal initialPayment { get; set; }
        private Decimal dOtherEquipment { get; set; }
        private Decimal dOtherEquipmentInstallation { get; set; }
        private Decimal dTankInstallation { get; set; }
        private Decimal dCivilWorksAndFencing { get; set; }
        private Decimal dProjects { get; set; }
        private Decimal dTankCost { get; set; }
        private Decimal totalInvestment { get; set; }

        public Integer SizeOfTanksToInstall { get { return tanksToInstall.size(); } }
        public Integer SizeOfOtherEquipments { get { return otherEquipmentsToInstall.size(); } }
        public Boolean areThereOutdoorsInstallation {get;set;}
        public Boolean areThereCivilWork {get;set;}
        public Boolean areThereProjectAndLegalization {get;set;}
        public Boolean areThereIndoorsEquipment {get;set;}

        public String outdoorsInstallation {get;set;}
        public String civilWorks {get;set;}
        public String projectAndLegalization {get;set;}
        public String indoorsEquipment {get;set;}

        public List<String> primaservicios { get; set; }

        public String annualEstimatedConsumption { get; set; }
        public String rate { get; set; }
        public String rateName { get; set;}

        public Map<Integer, StretcherWrapper> stretchesByIndex {get;set;}
        public Integer SizeOfStretchesByIndex { get { return stretchesByIndex.size(); }}
        public Decimal totalDiscounts { get; set; }
        public Decimal primaserviciosPrice { get; set; }
        public Decimal mWhPrice { get; set; }

        public String contractDuration {get;set;}
        public String paymentConditionDays {get;set;}

        public String additionalConditions {get;set;}

        public RecordWrapper(CPQ_Quote.QuoteWrapper w) {
            mWhPrice = 0;
            accountName = w.Quote.SBQQ__Account__r.Name;
            quoteDate = w.Quote.SBQQ__StartDate__c;
            county = w.Quote.County__c;
            additionalConditions = w.Quote.AdditionalConditions__c;

            tanksToInstall = new Map<String, Integer>();
            for (SBQQ__QuoteLine__c ql : w.getLinesByProductCode(CPQ_ProductCodes.DEPOSITO)) {
                if(String.isNotBlank(ql.TankName__c)){
                    if (!tanksToInstall.containsKey(ql.TankName__c)) {
                        tanksToInstall.put(ql.TankName__c, 1);
                    } else {
                        tanksToInstall.put(ql.TankName__c, tanksToInstall.get(ql.TankName__c) + 1);
                    }
                }
            }
            
            otherEquipmentsToInstall = new Map<String, Integer>();
            for (SBQQ__QuoteLine__c ql : w.getLinesByProductFamily(CPQ_ProductFamilies.OTROS_EQUIPOS)) {
                if (!otherEquipmentsToInstall.containsKey(ql.SBQQ__Product__r.Name)) {
                    otherEquipmentsToInstall.put(ql.SBQQ__Product__r.Name, Integer.valueOf(ql.SBQQ__Quantity__c));
                }
            }

            outdoorsInstallation = formatToEuroCurrency(CPQ_AggregateUtil.sumFieldForRecords(
                CPQ_QuoteLineService.filterQLIsWithTankName(w.getLinesByProductCode(CPQ_ProductCodes.INSTALACION)),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            ));
            areThereOutdoorsInstallation = CPQ_QuoteLineService.filterQLIsWithTankName(w.getLinesByProductCode(CPQ_ProductCodes.INSTALACION)).size() > 0;

            civilWorks = formatToEuroCurrency(CPQ_AggregateUtil.sumFieldForRecords(
                w.getLinesForMultipleProductCodes(
                    new List<String>{ CPQ_ProductCodes.OBRACIVIL }
                ),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            ));
            areThereCivilWork = w.getLinesForMultipleProductCodes(new List<String>{ CPQ_ProductCodes.OBRACIVIL }).size() > 0;

            projectAndLegalization = formatToEuroCurrency(CPQ_AggregateUtil.sumFieldForRecords(
                w.getLinesForMultipleProductCodes(new List<String>{CPQ_ProductCodes.LEGALIZACION, CPQ_ProductCodes.PROYECTOMEMORIA}),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            ));
            areThereProjectAndLegalization = w.getLinesForMultipleProductCodes(new List<String>{CPQ_ProductCodes.LEGALIZACION, CPQ_ProductCodes.PROYECTOMEMORIA}).size() > 0;
            
            indoorsEquipment = formatToEuroCurrency(CPQ_AggregateUtil.sumFieldForRecords(
                CPQ_QuoteLineService.filterQLIsWithIndoorEquipment(w.getLinesByProductFamily(CPQ_ProductFamilies.OTROS_EQUIPOS)), 
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            ));
            areThereIndoorsEquipment = CPQ_QuoteLineService.filterQLIsWithIndoorEquipment(w.getLinesByProductFamily(CPQ_ProductFamilies.OTROS_EQUIPOS)).size() > 0;

            customerCost = formatToEuroCurrency(CPQ_AggregateUtil.sumFieldForRecords(
                w.getLinesForMultipleProductCodes(new List<String>{CPQ_ProductCodes.PAGOINICIAL, CPQ_ProductCodes.CUOTASALQUILER}),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            ));

            initialPayment = CPQ_AggregateUtil.sumFieldForRecords(
                w.getLinesByProductCode(CPQ_ProductCodes.PAGOINICIAL),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dOtherEquipment = CPQ_AggregateUtil.sumFieldForRecords(
                w.getLinesByProductFamily(CPQ_ProductFamilies.OTROS_EQUIPOS),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dOtherEquipmentInstallation = CPQ_AggregateUtil.sumFieldForRecords(
                CPQ_QuoteLineService.filterQLIsWithNoTankName(w.getLinesByProductCode(CPQ_ProductCodes.INSTALACION)),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dTankInstallation = CPQ_AggregateUtil.sumFieldForRecords(
                CPQ_QuoteLineService.filterQLIsWithTankName(w.getLinesByProductCode(CPQ_ProductCodes.INSTALACION)),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dCivilWorksAndFencing = CPQ_AggregateUtil.sumFieldForRecords(
                w.getLinesForMultipleProductCodes(
                    new List<String>{ CPQ_ProductCodes.VALLADO, CPQ_ProductCodes.OBRACIVIL }
                ),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dProjects = CPQ_AggregateUtil.sumFieldForRecords(
                w.getLinesByProductCode(CPQ_ProductCodes.PROYECTOMEMORIA),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dTankCost = CPQ_AggregateUtil.sumFieldForRecords(
                w.getLinesByProductCode(CPQ_ProductCodes.DEPOSITO),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );
            
            primagasCost = formatToEuroCurrency(
                dTankCost + dTankInstallation + dProjects + dCivilWorksAndFencing + 
                dOtherEquipment + dOtherEquipmentInstallation - initialPayment - Decimal.valueOf(customerCost.remove(' €'))
            );

            primaservicios = new List<String>();
            for (SBQQ__QuoteLine__c ql : w.getLinesByProductFamily(CPQ_ProductFamilies.PRIMASERVICIOS)) {
                // Exclude the PRIMASERVICIOS product itself:
                if (ql.SBQQ__Product__r.ProductCode != CPQ_ProductCodes.PRIMASERVICIOS) {
                    primaservicios.add(ql.SBQQ__Product__r.Name);
                }
            }

            annualEstimatedConsumption = w.Quote.EstimatedConsumption__c+' kg';
            rate = String.valueOf(w.Rate);
            rateName = w.getFirstLineByProductFamilyExcludingProductCodes(CPQ_ProductFamilies.TARIFAS,
                        new Set<String>{CPQ_ProductCodes.TARIFA}).SBQQ__PRODUCT__R.Name;
            
            contractDuration = String.valueOf(w.Quote.Duration__c);
            paymentConditionDays = w.Quote.PaymentTerm__c;

            stretchesByIndex = new Map<Integer, StretcherWrapper>();

            Integer stretchIndex = 1;
            for(Stretch__c s : CPQ_StretchSelector.selectByQuotesId(new Set<Id>{w.Quote.Id})){
                stretchesByIndex.put(stretchIndex++, new StretcherWrapper(s, s.FromPercentage__c == CPQ_Stretch.DEFAUT_QUOTE_STRETCH_FROM_PERCENTAGE));
            }

            totalDiscounts = CPQ_AggregateUtil.sumFieldForRecords(
                w.getLinesByProductCode(CPQ_ProductCodes.DESCTARIFA),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            primaserviciosPrice = CPQ_AggregateUtil.sumFieldForRecords(
                w.getLinesByProductFamily(CPQ_ProductFamilies.PRIMASERVICIOS),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            if (w.Rate != null && w.Rate != 0) {
                mWhPrice = w.Rate * CONVERSION_FACTOR_KG_MWH;
            }
        }
    }

    private static String formatToEuroCurrency(Decimal value){
        return value.format() + ' €';
    }
    
    public class StretcherWrapper {
        public Stretch__c record {get;set;}
        public Boolean isSelected {get;set;}

        public StretcherWrapper(Stretch__c record, Boolean isSelected){
            this.record = record;
            this.isSelected = isSelected;
        }

        public Decimal getMWhPrice(){
            if (this.record.PriceTodayKG__c != null && this.record.PriceTodayKG__c != 0){
                return this.record.PriceTodayKG__c * CONVERSION_FACTOR_KG_MWH;
            }
            return 0;
        }
    }
}