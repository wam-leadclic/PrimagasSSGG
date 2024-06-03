//Generated by wsdl2apex

public class SchemaContrato {
    public class entitySyncDto {
        public SchemaContrato.etContract[] etContract;
        private String[] etContract_type_info = new String[]{'etContract','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:microsoft-dynamics-nav/xmlports/x50056','true','false'};
        private String[] field_order_type_info = new String[]{'etContract'};
    }
    public class etContract {
        public String CustomerNavCode;
        public String ShiptoCode;
        public String ContractType;
        public Decimal ContractDurationTons;
        public Decimal ContractDurationYears;
        public Decimal PlannedConsumptionTons;
        public String PaymentTermsServices;
        public String PaymentMetodServices;
        public String PaymentTermsFuel;
        public String PaymentMethodFuel;
        public String CodePaymentDay;
        public String ReminderTermsCode;
        public Date DateFirstFill;
        public Date DateCivilWork;
        public String Subcontractor;
        public Decimal CapacityTank;
        public Boolean Carburante;
        public String TankType;
        public Decimal AmountDepo;
        public Decimal AmountINEX;
        public Decimal AmountININ;
        public Decimal AmountOC;
        public Decimal AmountEquipment;
        public Decimal AmountProyect;
        public Decimal dpcadmin1;
        public Decimal dpcadmin2;
        public Decimal dpcadmin3;
        public Decimal dpcadmin4;
        public Decimal dpcadmin5;
        public Decimal dpcadmin6;
        public String Tariff;
        public Decimal Dto1;
        public Decimal Dto2;
        public Decimal Dto3;
        public Decimal Dto4;
        public Decimal Dto5;
        public Decimal Dto6;
        public String TPinstallationType;
        public Decimal Dto1kg;
        public Decimal Dto2kg;
        public Decimal Dto3kg;
        public Decimal Dto4kg;
        public Decimal Dto5kg;
        public Decimal Dto6kg;
        public String Services;
        public Decimal dcmpropano1;
        public Decimal dcmpropano2;
        public Decimal dcmpropano3;
        public Decimal dcmpropano4;
        public Decimal AmountServices;
        public Decimal Dto1Year;
        public Decimal Dto2Year;
        public Decimal Dto3Year;
        public Decimal Dto4Year;
        public Decimal AmountContractManagement;
        public Decimal GasMeterRentAmount;
        public Decimal AmountSAU;
        public Decimal ImporteDerechosAlta;
        public Decimal ImporteDerechosAcometida;
        public Decimal AmountFixTerm;
        public Decimal AmountForfait;
        public Decimal AmountPrima;
        public Boolean WaterAvailable;
        public String Promotor;
        public String ConsumptionProfile;
        public String ContractedProduct;
        public String Segment1;
        public String Segment2;
        public String SubActivity;
        public Boolean Primaconta;
        public Boolean Telemedida;
        public String CanalizadoPromotor;
        public String TruckType;
        public String DeliveryItem;
        public String BankIBAN;
        public String BankSWIFT;
        public String ModalidadInstalacion;
        public Boolean SplitFirstPaymentIn3;
        public String OldCustomerNavCode;
        public String OldShiptoCode;
        public Integer LastMeterReading;
        public Date StartDate;
        public String IDSalesForce;
        private String[] CustomerNavCode_type_info = new String[]{'CustomerNavCode','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] ShiptoCode_type_info = new String[]{'ShiptoCode','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] ContractType_type_info = new String[]{'ContractType','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] ContractDurationTons_type_info = new String[]{'ContractDurationTons','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] ContractDurationYears_type_info = new String[]{'ContractDurationYears','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] PlannedConsumptionTons_type_info = new String[]{'PlannedConsumptionTons','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] PaymentTermsServices_type_info = new String[]{'PaymentTermsServices','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] PaymentMetodServices_type_info = new String[]{'PaymentMetodServices','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] PaymentTermsFuel_type_info = new String[]{'PaymentTermsFuel','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] PaymentMethodFuel_type_info = new String[]{'PaymentMethodFuel','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] CodePaymentDay_type_info = new String[]{'CodePaymentDay','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] ReminderTermsCode_type_info = new String[]{'ReminderTermsCode','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] DateFirstFill_type_info = new String[]{'DateFirstFill','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] DateCivilWork_type_info = new String[]{'DateCivilWork','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Subcontractor_type_info = new String[]{'Subcontractor','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] CapacityTank_type_info = new String[]{'CapacityTank','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Carburante_type_info = new String[]{'Carburante','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] TankType_type_info = new String[]{'TankType','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] AmountDepo_type_info = new String[]{'AmountDepo','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] AmountINEX_type_info = new String[]{'AmountINEX','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] AmountININ_type_info = new String[]{'AmountININ','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] AmountOC_type_info = new String[]{'AmountOC','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] AmountEquipment_type_info = new String[]{'AmountEquipment','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] AmountProyect_type_info = new String[]{'AmountProyect','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] dpcadmin1_type_info = new String[]{'dpcadmin1','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] dpcadmin2_type_info = new String[]{'dpcadmin2','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] dpcadmin3_type_info = new String[]{'dpcadmin3','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] dpcadmin4_type_info = new String[]{'dpcadmin4','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] dpcadmin5_type_info = new String[]{'dpcadmin5','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] dpcadmin6_type_info = new String[]{'dpcadmin6','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Tariff_type_info = new String[]{'Tariff','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto1_type_info = new String[]{'Dto1','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto2_type_info = new String[]{'Dto2','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto3_type_info = new String[]{'Dto3','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto4_type_info = new String[]{'Dto4','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto5_type_info = new String[]{'Dto5','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto6_type_info = new String[]{'Dto6','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] TPinstallationType_type_info = new String[]{'TPinstallationType','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto1kg_type_info = new String[]{'Dto1kg','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto2kg_type_info = new String[]{'Dto2kg','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto3kg_type_info = new String[]{'Dto3kg','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto4kg_type_info = new String[]{'Dto4kg','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto5kg_type_info = new String[]{'Dto5kg','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto6kg_type_info = new String[]{'Dto6kg','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Services_type_info = new String[]{'Services','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] dcmpropano1_type_info = new String[]{'dcmpropano1','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] dcmpropano2_type_info = new String[]{'dcmpropano2','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] dcmpropano3_type_info = new String[]{'dcmpropano3','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] dcmpropano4_type_info = new String[]{'dcmpropano4','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] AmountServices_type_info = new String[]{'AmountServices','urn:microsoft-dynamics-nav/xmlports/x50056',null,'1','1','false'};
        private String[] Dto1Year_type_info = new String[]{'Dto1Year','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto2Year_type_info = new String[]{'Dto2Year','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto3Year_type_info = new String[]{'Dto3Year','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Dto4Year_type_info = new String[]{'Dto4Year','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] AmountContractManagement_type_info = new String[]{'AmountContractManagement','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] GasMeterRentAmount_type_info = new String[]{'GasMeterRentAmount','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] AmountSAU_type_info = new String[]{'AmountSAU','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] ImporteDerechosAlta_type_info = new String[]{'ImporteDerechosAlta','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] ImporteDerechosAcometida_type_info = new String[]{'ImporteDerechosAcometida','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] AmountFixTerm_type_info = new String[]{'AmountFixTerm','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] AmountForfait_type_info = new String[]{'AmountForfait','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] AmountPrima_type_info = new String[]{'AmountPrima','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] WaterAvailable_type_info = new String[]{'WaterAvailable','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Promotor_type_info = new String[]{'Promotor','urn:microsoft-dynamics-nav/xmlports/x50056',null,'1','1','false'};
        private String[] ConsumptionProfile_type_info = new String[]{'ConsumptionProfile','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] ContractedProduct_type_info = new String[]{'ContractedProduct','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Segment1_type_info = new String[]{'Segment1','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Segment2_type_info = new String[]{'Segment2','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] SubActivity_type_info = new String[]{'SubActivity','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] Primaconta_type_info = new String[]{'Primaconta','urn:microsoft-dynamics-nav/xmlports/x50056',null,'1','1','false'};
        private String[] Telemedida_type_info = new String[]{'Telemedida','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] CanalizadoPromotor_type_info = new String[]{'CanalizadoPromotor','urn:microsoft-dynamics-nav/xmlports/x50056',null,'1','1','false'};
        private String[] TruckType_type_info = new String[]{'TruckType','urn:microsoft-dynamics-nav/xmlports/x50056',null,'1','1','false'};
        private String[] DeliveryItem_type_info = new String[]{'DeliveryItem','urn:microsoft-dynamics-nav/xmlports/x50056',null,'1','1','false'};
        private String[] BankIBAN_type_info = new String[]{'BankIBAN','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] BankSWIFT_type_info = new String[]{'BankSWIFT','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] ModalidadInstalacion_type_info = new String[]{'ModalidadInstalacion','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] SplitFirstPaymentIn3_type_info = new String[]{'SplitFirstPaymentIn3','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] OldCustomerNavCode_type_info = new String[]{'OldCustomerNavCode','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] OldShiptoCode_type_info = new String[]{'OldShiptoCode','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] LastMeterReading_type_info = new String[]{'LastMeterReading','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] StartDate_type_info = new String[]{'StartDate','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] IDSalesForce_type_info = new String[]{'IDSalesForce','urn:microsoft-dynamics-nav/xmlports/x50056',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:microsoft-dynamics-nav/xmlports/x50056','true','false'};
        private String[] field_order_type_info = new String[]{'CustomerNavCode','ShiptoCode','ContractType','ContractDurationTons','ContractDurationYears','PlannedConsumptionTons','PaymentTermsServices','PaymentMetodServices','PaymentTermsFuel','PaymentMethodFuel','CodePaymentDay','ReminderTermsCode','DateFirstFill','DateCivilWork','Subcontractor','CapacityTank','Carburante','TankType','AmountDepo','AmountINEX','AmountININ','AmountOC','AmountEquipment','AmountProyect','dpcadmin1','dpcadmin2','dpcadmin3','dpcadmin4','dpcadmin5','dpcadmin6','Tariff','Dto1','Dto2','Dto3','Dto4','Dto5','Dto6','TPinstallationType','Dto1kg','Dto2kg','Dto3kg','Dto4kg','Dto5kg','Dto6kg','Services','dcmpropano1','dcmpropano2','dcmpropano3','dcmpropano4','AmountServices','Dto1Year','Dto2Year','Dto3Year','Dto4Year','AmountContractManagement','GasMeterRentAmount','AmountSAU','ImporteDerechosAlta','ImporteDerechosAcometida','AmountFixTerm','AmountForfait','AmountPrima','WaterAvailable','Promotor','ConsumptionProfile','ContractedProduct','Segment1','Segment2','SubActivity','Primaconta','Telemedida','CanalizadoPromotor','TruckType','DeliveryItem','BankIBAN','BankSWIFT','ModalidadInstalacion','SplitFirstPaymentIn3','OldCustomerNavCode','OldShiptoCode','LastMeterReading','StartDate','IDSalesForce'};
    }
}