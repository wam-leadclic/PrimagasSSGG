public with sharing class CPQ_PBAService {
    public static final Integer MAX_PBA_YEARS = 100;
    private static final Integer FIRST_YEAR = 1;
    public static final Decimal FULL_ESTIMATED_CONSUMPTION_COEF = 1;

    public static PBAParams build(
        CPQ_Quote.QuoteWrapper quoteWrapper,
        Stretch__c stretch,
        CPQ_TablesDataWrapper tablesData,
        Decimal estimatedConsumptionCoef
    ) {
        return generateParamsForYears(1, quoteWrapper, stretch, tablesData, estimatedConsumptionCoef)[0];
    }

    public static PBAParams build(
        CPQ_Quote.QuoteWrapper quoteWrapper,
        CPQ_TablesDataWrapper tablesData,
        Decimal estimatedConsumptionCoef
    ) {
        return generateParamsForYears(1, quoteWrapper, null, tablesData, estimatedConsumptionCoef)[0];
    }

    public static List<PBAParams> generateParamsForYears(
        Integer nYears,
        CPQ_Quote.QuoteWrapper quoteWrapper,
        Stretch__c stretch,
        CPQ_TablesDataWrapper tablesData,
        Decimal estimatedConsumptionCoef
    ) {
        List<PBAParams> output = new List<PBAParams>();
        for (Integer i = 1; i <= nYears; i++) {
            PBAParams pba = new PBAParams(i, quoteWrapper, stretch, tablesData, estimatedConsumptionCoef);
            pba.calculateFields();
            output.add(pba);
        }

        return output;
    }

    public class PBAParams {
        private Decimal dGasMarginEuroKG;
        // Margen del gas €/Kg
        public Decimal GasMarginEuroKG {
            get {
                return dGasMarginEuroKG;
            }
        }
        // Precio €/Kg
        private Decimal dPriceEuroKG;

        // Importe tarifa
        private Decimal dFeeAmount;
        public Decimal FeeAmount {
            get {
                return dFeeAmount;
            }
        }
        // Descuento €/kg
        private Decimal dDiscountEuroKG;
        public Decimal DiscountEuroKG {
            get {
                return dDiscountEuroKG;
            }
        }
        // Duracion de descuento (años)
        private Decimal dDiscountDurationInYears;
        public Decimal DiscountDurationInYears {
            get {
                return dDiscountDurationInYears;
            }
        }

        // Descuento
        private Decimal dDiscount;

        public Decimal Discount {
            get{
                return dDiscount;
            }
        }

        // Coste del gas
        private Decimal dGasCost;
        public Decimal GasCost {
            get {
                return dGasCost;
            }
        }
        // Coste transporte
        private Decimal dTransportationCost;
        public Decimal TransportationCost {
            get {
                return dTransportationCost;
            }
        }
        // Consumo anual (Kg)
        private Decimal dAnnualConsumptionKG;
        public Decimal AnnualConsumptionKG {
            get {
                return dAnnualConsumptionKG;
            }
        }
        // Margen de gas
        private Decimal dGasMargin;
        public Decimal GasMargin {
            get {
                return dGasMargin;
            }
        }

        private Decimal dGasMarginCoef;
        public Decimal GasMarginCoef {
            get {
                return dGasMarginCoef;
            }
        }

        // DTO 1er llenado
        private Decimal dFirstFillDiscount;
        public Decimal FirstFillDiscount {
            get {
                return dFirstFillDiscount;
            }
        }

        // Otros Servicios
        private Decimal dPrimaservicios;
        public Decimal Primaservicios {
            get {
                return dPrimaservicios;
            }
        }

        // Otros Servicios (anual)
        private Decimal dPrimaserviciosAnnual;
        public Decimal PrimaserviciosAnnual {
            get {
                return dPrimaserviciosAnnual;
            }
        }
        // Ingreso Cuota Inversion (anual)
        private Decimal dAnnualInvestmentFeeIncome;
        public Decimal AnnualInvestmentFeeIncome {
            get {
                return dAnnualInvestmentFeeIncome;
            }
        }
        // Cuota inversion €/mes
        private Decimal dInvestmentFeeEuroMonth;
        public Decimal InvestmentFeeEuroMonth {
            get {
                return dInvestmentFeeEuroMonth;
            }
        }
        // Duracion Cuota (meses)
        private Decimal dFeeDuration;
        public Decimal FeeDuration {
            get {
                return dFeeDuration;
            }
        }

        // Coste de mantenimiento (anual)
        private Decimal dTankMaintenanceCost;
        public Decimal TankMaintenanceCost {
            get {
                return dTankMaintenanceCost;
            }
        }
        // Coste de servicios extra (anual)
        private Decimal dServicesCost;
        public Decimal ServicesCost {
            get {
                return dServicesCost;
            }
        }

        // Ingreso Cuota alquiler (anual)
        private Decimal dAnnualRentFeeIncome;
        public Decimal AnnualRentFeeIncome {
            get {
                return dAnnualRentFeeIncome;
            }
        }
        // Cuota alquiler €/mes
        private Decimal dRentFeeEuroMonth;
        public Decimal RentFeeEuroMonth {
            get {
                return dRentFeeEuroMonth;
            }
        }
        // Duracion Cuota alquiler (meses)
        private Integer dRentFeeDurationMonths;
        public Integer RentFeeDurationMonths {
            get {
                return dRentFeeDurationMonths;
            }
        }

        private Decimal dTotalMargin;
        // MARGEN TOTAL
        public Decimal TotalMargin {
            get {
                return dTotalMargin;
            }
        }
        // TOTAL INVERSION
        private Decimal dTotalInvestment;
        public Decimal TotalInvestment {
            get {
                return dTotalInvestment;
            }
        }
        // Total Deposito
        private Decimal dTankTotal;
        public Decimal TankTotal {
            get {
                return dTankTotal;
            }
        }
        // Coste deposito
        private Decimal dTankCost;
        public Decimal TankCost {
            get {
                return this.dTankCost;
            }
        }
        // Proyectos
        private Decimal dProjects;
        public Decimal Projects {
            get {
                return this.dProjects;
            }
        }
        // Obra civil y vallado
        private Decimal dCivilWorksAndFencing;
        public Decimal CivilWorksAndFencing {
            get {
                return this.dCivilWorksAndFencing;
            }
        }
        // Total Equipo
        private Decimal dEquipmentTotal;
        public Decimal EquipmentTotal {
            get {
                return dEquipmentTotal;
            }
        }
        // Otros equipos
        private Decimal dOtherEquipment;
        public Decimal OtherEquipment {
            get {
                return dOtherEquipment;
            }
        }
        
        // Instalación otros equipos
        private Decimal dOtherEquipmentInstallation;
        public Decimal OtherEquipmentInstallation {
            get {
                return dOtherEquipmentInstallation;
            }
        }

        // Instalacion Exterior
        private Decimal dTankInstallation;
        public Decimal TankInstallation {
            get {
                return this.dTankInstallation;
            }
        }
        // Pago inicial
        private Decimal dInitialPayment;
        public Decimal InitialPayment {
            get {
                return this.dInitialPayment;
            }
        }

        // Crédito
        private Decimal dCredit;
        public Decimal Credit {
            get {
                return dCredit;
            }
        }
        // Inversión no recuperable
        private Decimal dNonRecoveryInvestment;
        public Decimal NonRecoveryInvestment {
            get {
                return dNonRecoveryInvestment;
            }
        }

        private Decimal dRecoverableAmount;
        public Decimal RecoverableAmount {
            get{
                return dRecoverableAmount;
            }
        }

        // Margen de gas
        // Warning: this property is calculated based on year dependent values (dDiscount).
        //          if you want to get the first year's MargenDeGas, please get the value before
        //          calculating the PBA result.
        public Decimal MargenDeGas {
            get {
                //return (FeeAmount - dDiscount - GasCost - TransportationCost) * dAnnualConsumptionKG * dGasMarginCoef;
                //Precio tarifa - descuento - coste del gas - transporte de gas
                return dFeeAmount - dDiscount - dGasCost - dTransportationCost;
            }
        }

        /**
         * Calculates the value for the fields which are based in other fields.
         */
        public void calculateFields() {
            CPQ_LogUtil.debug('PBA calculateFields '+dDiscountEuroKG);
            dDiscount = (dDiscountDurationInYears >= nYears) ? dDiscountEuroKG : 0;
            dPriceEuroKG = dFeeAmount - dDiscount;
            dGasMarginEuroKG = dPriceEuroKG - dGasCost - dTransportationCost;
            dGasMargin = dGasMarginEuroKG * dAnnualConsumptionKG * dGasMarginCoef;
            
            dPrimaserviciosAnnual = dPrimaservicios * 12;
            dAnnualRentFeeIncome = (dRentFeeDurationMonths <= 12 * nYears)
                ? dRentFeeEuroMonth * Math.max(0, dRentFeeDurationMonths - 12 * (nYears - 1))
                : dRentFeeEuroMonth * 12;

            dAnnualInvestmentFeeIncome = (dFeeDuration <= 12 * nYears)
                ? InvestmentFeeEuroMonth * Math.max(0, dFeeDuration - 12 * (nYears - 1))
                : InvestmentFeeEuroMonth * 12;

            dTotalMargin = dGasMargin + dAnnualInvestmentFeeIncome + dAnnualRentFeeIncome + dPrimaserviciosAnnual
                            - dServicesCost - dTankMaintenanceCost - ((nYears == FIRST_YEAR) ? dFirstFillDiscount : 0);

            dTankTotal = dTankCost + dTankInstallation + dProjects + dCivilWorksAndFencing;

            dEquipmentTotal = dOtherEquipment + dOtherEquipmentInstallation;
            dTotalInvestment = dTankTotal + dEquipmentTotal - dInitialPayment;
            dNonRecoveryInvestment = dTotalInvestment - dTankCost - dRecoverableAmount;

            printFields();
        }

        public void printFields(){
            if(CPQ_Settings.AreLogsEnabled){
                System.debug('[CPQ_PBAService] printFields --------------- YEARS: '+nYears);
                System.debug('[CPQ_PBAService] printFields --- Tarifa de gas: '+FeeAmount);
                System.debug('[CPQ_PBAService] printFields --- Descuento: '+Discount);
                System.debug('[CPQ_PBAService] printFields --- PriceEuroKG: '+dPriceEuroKG+' = '+dFeeAmount+' - '+dDiscount);
                System.debug('[CPQ_PBAService] printFields --- Margen de gas €/Kg: '+GasMarginEuroKG +' = '+dPriceEuroKG+' - '+dGasCost+' - '+TransportationCost);
                System.debug('[CPQ_PBAService] printFields --- Margen de gas: '+GasMargin);
                System.debug('[CPQ_PBAService] printFields --- Alquiler: '+dAnnualRentFeeIncome);
                System.debug('[CPQ_PBAService] printFields --- Cuota Inversión: '+AnnualInvestmentFeeIncome);
                System.debug('[CPQ_PBAService] printFields --- NonRecoveryInvestment: '+dTotalInvestment+ ' - '+dTankCost+ ' - '+dRecoverableAmount);
                System.debug('[CPQ_PBAService] printFields --- Margen total: '+TotalMargin+' = '+dGasMargin+' + '+dAnnualInvestmentFeeIncome+' + '+dAnnualRentFeeIncome+' + '+dPrimaserviciosAnnual+' - '+dServicesCost+' - '+dTankMaintenanceCost+' - '+((nYears == FIRST_YEAR) ? dFirstFillDiscount : 0));
                System.debug('[CPQ_PBAService] printFields ------ Ingresos primaservicios (anual): '+dPrimaserviciosAnnual);
                System.debug('[CPQ_PBAService] printFields ------ Coste de Servicios: '+dServicesCost);
                System.debug('[CPQ_PBAService] printFields ------ Mantenimiento de deposito: '+dTankMaintenanceCost);
                System.debug('[CPQ_PBAService] printFields ------ Descuento primer llenado '+FirstFillDiscount);
                System.debug('[CPQ_PBAService] printFields ------ Total Inversión: '+dTotalInvestment+' = '+dTankTotal+' + '+dEquipmentTotal+' - '+dInitialPayment);
                System.debug('[CPQ_PBAService] printFields ------ Total Depósitos: '+dTankTotal+' = '+dTankCost+' + '+dTankInstallation+' + '+dProjects+' + '+dCivilWorksAndFencing);
                System.debug('[CPQ_PBAService] printFields ------ Total Equipos: '+dEquipmentTotal+' = '+dOtherEquipment+' + '+dOtherEquipmentInstallation);
                System.debug('[CPQ_PBAService] printFields ------ Pago inicial: '+dInitialPayment);
                System.debug('[CPQ_PBAService] printFields ------ Margen De Gas: '+MargenDeGas);
            }
        }

        public Decimal calculateResult(){
            return calculateResult(0);
        }

        private Decimal calculateResult(Decimal sumTotalMargin){
            Decimal lastAccumlatedTotal = sumTotalMargin;

            calculateFields();
            if(nYears == FIRST_YEAR){
                sumTotalMargin += TotalMargin - dTotalInvestment;
            }else{
                sumTotalMargin += TotalMargin;
            }
            
            if(nYears < MAX_PBA_YEARS){
                CPQ_LogUtil.debug('[CPQ_PBAService.calculateResult] Year: ' + nYears + ' (TotalMargin: '+TotalMargin+', sumTotalMargin: ' + sumTotalMargin+' TotalInvestment: '+TotalInvestment+')');
                if (sumTotalMargin < 0) {
                    nYears++;
                    return calculateResult(sumTotalMargin);
                } else {
                    if(sumTotalMargin == 0){
                        System.debug('TotalMargin is zero');
                        return null;
                        //throw new CPQ_MissingFieldException('TotalMargin is zero.');
                    }

                    Decimal pbaResult = 0;

                    if(nYears == FIRST_YEAR){
                        pbaResult = dTotalInvestment / TotalMargin;
                        CPQ_LogUtil.debug('[CPQ_PBAService.calculateResult] PBA is '+pbaResult+ ' = ' + dTotalInvestment+ ' / ' +TotalMargin);
                    }else{
                        pbaResult = nYears - 1 - lastAccumlatedTotal / TotalMargin;
                        CPQ_LogUtil.debug('[CPQ_PBAService.calculateResult] PBA is '+pbaResult+ ' = ' +(nYears - 1) +' - '+ lastAccumlatedTotal+ ' / ' +TotalMargin);
                    }
                    return pbaResult;
                }
            }else{
                CPQ_LogUtil.debug('Max years reached.');
                return null;
                //throw new MaxPBAYearsException('Maximum number of calculation years reached for PBA.');
            }
        }

        private Integer nYears;

        public PBAParams(Integer nYears, Decimal estimatedConsumptionCoef) {
            this.nYears = nYears;
            this.dGasMarginCoef = estimatedConsumptionCoef;
        }

        public PBAParams(
            Integer nYears,
            CPQ_Quote.QuoteWrapper quoteWrapper,
            Stretch__c stretch,
            CPQ_TablesDataWrapper tablesData,
            Decimal estimatedConsumptionCoef
        ) {
            this(nYears, quoteWrapper, tablesData, estimatedConsumptionCoef);

            if (stretch != null) {
                // Overwrite values with the stretcher fields:
                if (stretch.FromConsumptionKG__c == null) {
                    throw new CPQ_MissingFieldException('stretch.FromConsumptionKG__c is not set.');
                }
                dAnnualConsumptionKG = stretch.FromConsumptionKG__c;

                if (stretch.DiscountKG__c == null) {
                    //throw new CPQ_MissingFieldException('stretch.DiscountKG__c is not set.');
                    stretch.DiscountKG__c = 0;
                }
                CPQ_LogUtil.debug('---------------- SET Discount from stretch');
                dDiscountEuroKG = stretch.DiscountKG__c;

                if (stretch.PrimaServiciosA__c == null) {
                    //throw new CPQ_MissingFieldException('stretch.PrimaServiciosA__c is not set.');
                    stretch.PrimaserviciosA__c = 0;
                }
                dPrimaservicios = stretch.PrimaServiciosA__c;
            }
        }

        public PBAParams(
            Integer nYears,
            CPQ_Quote.QuoteWrapper quoteWrapper,
            CPQ_TablesDataWrapper tablesData,
            Decimal estimatedConsumptionCoef
        ) {
            this.nYears = nYears;
            this.dGasMarginCoef = estimatedConsumptionCoef;

            // Quote info
            dAnnualConsumptionKG = quoteWrapper.EstimatedConsumption;
            // Manual input
            dInitialPayment = CPQ_AggregateUtil.sumFieldForRecords(
                quoteWrapper.getLinesByProductCode(CPQ_ProductCodes.PAGOINICIAL),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dOtherEquipment = CPQ_AggregateUtil.sumFieldForRecords(
                quoteWrapper.getLinesByProductFamily(CPQ_ProductFamilies.OTROS_EQUIPOS),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dOtherEquipmentInstallation = CPQ_AggregateUtil.sumFieldForRecords(
                CPQ_QuoteLineService.filterQLIsWithNoTankName(quoteWrapper.getLinesByProductCode(CPQ_ProductCodes.INSTALACION)),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dTankInstallation = CPQ_AggregateUtil.sumFieldForRecords(
                CPQ_QuoteLineService.filterQLIsWithTankName(quoteWrapper.getLinesByProductCode(CPQ_ProductCodes.INSTALACION)),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dCivilWorksAndFencing = CPQ_AggregateUtil.sumFieldForRecords(
                quoteWrapper.getLinesForMultipleProductCodes(
                    new List<String>{ CPQ_ProductCodes.VALLADO, CPQ_ProductCodes.OBRACIVIL }
                ),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dProjects = CPQ_AggregateUtil.sumFieldForRecords(
                quoteWrapper.getLinesByProductCode(CPQ_ProductCodes.PROYECTOMEMORIA),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dTankCost = CPQ_AggregateUtil.sumFieldForRecords(
                quoteWrapper.getLinesByProductCode(CPQ_ProductCodes.DEPOSITO),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );

            dRentFeeDurationMonths = (Integer) CPQ_AggregateUtil.convertToZeroIfNull(
                quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.CUOTASALQUILER)?.SBQQ__Quantity__c
            );

            dRentFeeEuroMonth = CPQ_AggregateUtil.convertToZeroIfNull(
                quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.CUOTASALQUILER)?.SBQQ__NetPrice__c
            );
            dFeeDuration = CPQ_AggregateUtil.convertToZeroIfNull(
                quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.CUOTASINVERSION)?.SBQQ__Quantity__c
            );
            dInvestmentFeeEuroMonth = CPQ_AggregateUtil.convertToZeroIfNull(
                quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.CUOTASINVERSION)?.SBQQ__NetPrice__c
            );

            // From QLI:
            CPQ_LogUtil.debug('---------------- SET Discount from QLI');

            dDiscountEuroKG = quoteWrapper.DiscountEuroKG;
            
            dDiscountDurationInYears = quoteWrapper.DiscountDurationInYears;
            dFeeAmount = quoteWrapper.Rate;
            
            dTankMaintenanceCost = CPQ_AggregateUtil.convertToZeroIfNull(
                tablesData.tmc.getFirstForCountyAndTankName(
                        quoteWrapper.Quote.County__c,
                        quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.DEPOSITO)?.TankName__c
                    )
                    ?.Cost__c
            );
            dFirstFillDiscount = CPQ_AggregateUtil.convertToZeroIfNull(
                quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.DESC1LLENADO)?.SBQQ__NetTotal__c
            );

            dPrimaservicios = quoteWrapper.Primaservicios;
            
            Set<Id> primaserviciosProductsId = new Set<Id>(
                CPQ_AggregateUtil.getFieldOfTypeIdForRecords(quoteWrapper.getLinesByProductFamily(CPQ_ProductFamilies.PRIMASERVICIOS),
                SBQQ__QuoteLine__c.Fields.SBQQ__Product__c));

            dServicesCost = CPQ_AggregateUtil.sumFieldForRecords(
                tablesData.sc.getForCountyAndProducts(quoteWrapper.Quote.County__c, primaserviciosProductsId),
                quoteWrapper.IsDomestic ? ServiceCost__c.Fields.DomesticCost__c : ServiceCost__c.Fields.ProfessionalCost__c);

            dGasCost = CPQ_AggregateUtil.convertToZeroIfNull(
                tablesData.gc.getForCounty(quoteWrapper.Quote.County__c)?.Cost__c
            );
            
            dTransportationCost = CPQ_AggregateUtil.convertToZeroIfNull(
                tablesData.gc.getForCounty(quoteWrapper.Quote.County__c)?.TransportationCost__c
            );

            dCredit = dAnnualConsumptionKG * (quoteWrapper.Rate - dDiscountEuroKG) - dFirstFillDiscount;

            dRecoverableAmount = CPQ_AggregateUtil.sumFieldForRecords(
                quoteWrapper.getLinesForMultipleProductCodes(new List<String>(tablesData.emd.filterProductCodesRecoverable(quoteWrapper.UniqueProductCodes))),
                SBQQ__QuoteLine__c.Fields.SBQQ__NetTotal__c
            );
        }

    }

    public class MaxPBAYearsException extends CPQ_MetricException {
        
    }
}