public with sharing class CPQ_CLVService {
    public static Decimal calculateResult(
        Integer nYears,
        CPQ_Quote.QuoteWrapper quoteWrapper,
        Stretch__c stretch,
        CPQ_TablesDataWrapper tablesData,
        Decimal estimatedConsumptionCoef
    ) {
        List<CPQ_PBAService.PBAParams> pbas = CPQ_PBAService.generateParamsForYears(
            nYears,
            quoteWrapper,
            stretch,
            tablesData,
            estimatedConsumptionCoef
        );

        CLVParams clv = new CLVParams(1, nYears, quoteWrapper, pbas[0], tablesData);
        Decimal totalYearsResult = clv.calculateYearResult(1);

        for (Integer i = 2; i <= nYears; i++) {
            clv = new CLVParams(i, nYears, pbas[i - 1], clv);
            clv.printFields();
            Decimal yearResult = (i < nYears) ? clv.calculateYearResult(i) : clv.calculateLastYearResult(i);
            totalYearsResult += yearResult;
            CPQ_LogUtil.debug('[CPQ_CLVService] calculateResult '+i+' Total margin: '+clv.TotalMargin
                        +' Year result: '+yearResult+' totalYearsResult: '+totalYearsResult);
        }
        Decimal clvResult = totalYearsResult - clv.TotalInvestment;
        CPQ_LogUtil.debug('[CPQ_CLVService] calculateResult CLV is '+clvResult);
        return clvResult;
    }

    public class CLVParams {
        public Integer clvYears;
        public Integer currentYear;

        // MARGEN TOTAL
        private Decimal dTotalMargin = 0;
        public Decimal TotalMargin {
            get {
                return dTotalMargin;
            }
        }

        // % tasa descuento
        public Decimal DiscountFeeCoef {
            get {
                return CPQ_Settings.DiscountRateCoef;
            }
        }

        // Años Dep.
        public Integer DepYears {
            get {
                return CPQ_Settings.DepYears;
            }
        }

        // Factor Dep. Xaños
        public Decimal DepFactorYears {
            get {
                if (clvYears <= 5) {
                    return CPQ_Settings.DepRate5Years;
                } else {
                    return CPQ_Settings.DepRate10Years;
                }
            }
        }

        //Deposito
        public Decimal dDeposit = 0;
        public Decimal Deposit {
            get {
                return dDeposit;
            }
            set {
                this.dDeposit = value;
            }
        }

        //Coste deposito
        public Decimal dTankCost = 0;
        public Decimal TankCost {
            get {
                return dTankCost;
            }
            set {
                this.dTankCost = value;
            }
        }

        //Deposito Depre.
        private Decimal dTankDepre;
        public Decimal TankDepre {
            get {
                return dTankDepre;
            }
        }

        //Desmantelamiento
        public Decimal dDismantling = 0;
        public Decimal Dismantling {
            get {
                return dDismantling;
            }
            set {
                this.dDismantling = value;
            }
        }

        // Resultado Año X
        public Decimal calculateYearResult(Integer nYear) {
            Decimal r = TotalMargin / Math.pow((Double) (1 + DiscountFeeCoef), (Double) nYear);
            CPQ_LogUtil.debug('[CPQ_CLVService] calculateYearResult '+nYear+': '+r+' = '+TotalMargin+' / (1 + '+DiscountFeeCoef+')^'+nYear);
            return r;
        }

        public Decimal calculateLastYearResult(Integer nYear) {
            Decimal r = (TotalMargin + TankDepre - Dismantling) /
                Math.pow((Double) (1 + DiscountFeeCoef), (Double) nYear);

            CPQ_LogUtil.debug('[CPQ_CLVService] calculateLastYearResult '+nYear+': '+r+' = ('+TotalMargin+' + '+TankDepre+' - '+Dismantling+') / (1 + '+DiscountFeeCoef+')^'+nYear);

            return r;
        }

        Decimal dInitialPayment = 0;
        public Decimal InitialPayment {
            get {
                return dInitialPayment;
            }
        }

        Decimal dTankTotal = 0;
        public Decimal TankTotal {
            get {
                return dTankTotal;
            }
        }

        Decimal dTotalEquipment = 0;
        public Decimal TotalEquipment {
            get {
                return dTotalEquipment;
            }
        }

        private Decimal dTotalInvestment = 0;
        //TOTAL INVERSION
        public Decimal TotalInvestment {
            get {
                return dTotalInvestment;
            }
        }

        private void setFieldsFromPBA(CPQ_PBAService.PBAParams pba) {
            dTankTotal = pba.TankTotal;
            dTotalEquipment = pba.EquipmentTotal;
            dInitialPayment = pba.InitialPayment;
            dTotalMargin = pba.TotalMargin;
            dTankCost = pba.TankCost;
            dTotalInvestment = pba.TotalInvestment;
            dTankDepre = dTankCost / DepYears * DepFactorYears;
        }

        public CLVParams(Integer currentYear, Integer clvYears, CPQ_PBAService.PBAParams pba, CLVParams p) {
            this.currentYear = currentYear;
            this.clvYears = clvYears;

            setFieldsFromPBA(pba);
            dDismantling = p.Dismantling;
        }

        public CLVParams(
            Integer currentYear,
            Integer clvYears,
            CPQ_Quote.QuoteWrapper quoteWrapper,
            CPQ_PBAService.PBAParams pba,
            CPQ_TablesDataWrapper tablesData
        ) {
            this.currentYear = currentYear;
            this.clvYears = clvYears;

            setFieldsFromPBA(pba);
            dDismantling = CPQ_AggregateUtil.convertToZeroIfNull(
                tablesData.tmd.getFirstForName(quoteWrapper.getFirstLineByProductCode(CPQ_ProductCodes.DEPOSITO)?.TankName__c)
                    ?.Dismantle__c
            );
        }

        public void printFields(){
            if(CPQ_Settings.AreLogsEnabled){
                System.debug('[CPQ_CLVService] printFields --------------- YEAR: '+currentYear+'/'+clvYears);
                System.debug('[CPQ_CLVService] printFields --- Margen total: '+TotalMargin);
                System.debug('[CPQ_CLVService] printFields --- % Tasa Descuento: '+DiscountFeeCoef);
                System.debug('[CPQ_CLVService] printFields --- Años DEP: '+DepYears);
                System.debug('[CPQ_CLVService] printFields --- Factor DEP: '+DepFactorYears);
                System.debug('[CPQ_CLVService] printFields --- Depreciación: '+TankDepre+' = '+dTankCost+' / '+DepYears+' * '+DepFactorYears);
                System.debug('[CPQ_CLVService] printFields --- Total Invesión: '+TotalInvestment);
            }
        }
    }
}