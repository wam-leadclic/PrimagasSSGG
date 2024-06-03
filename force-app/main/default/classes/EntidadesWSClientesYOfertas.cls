global class EntidadesWSClientesYOfertas
{
    public class DatosCliente
    {
        public String nombre {get;set;} // nombre del cliente
        public String apellidos {get;set;} // apellidos del cliente
        public String dni {get;set;}//dni del contacto
        public String cif {get;set;}//cof de empresa
        public String identificador {get;set;}//identificador sf
        public String compania {get;set;} // compañía del cliente
        public String telefono {get;set;} // teléfono del cliente
        public String telefonoMovil {get;set;} // teléfono móvil del cliente
        public String fax {get;set;} // fax del cliente
        public String email {get;set;} // e-mail del cliente
        public String calle {get;set;} // información de la calle del cliente
        public String calleFacturacion {get;set;} // información de la calle de facturación del cliente
        public String provincia {get;set;} // descripción de la provincia del cliente
        public String provinciaFacturacion {get;set;} // descripción de la provincia de facturación del cliente
        public String cp {get;set;} // código postal del cliente
        public String cpFacturacion {get;set;} // código postal de facturación del cliente
        public String actividad {get;set;} // descripción de la actividad a la que se dedica el cliente
        //public String canal {get; set;} // descripción del canal del cliente
        public String poblacion {get;set;} // población del cliente
        public String poblacionFacturacion {get;set;} // población de facturación del cliente
        public String subactividad {get;set;} // descripción de la subactvidad a la que se dedica el cliente
        //public String prescriptor {get;set;} // información del prescriptor del cliente
        public String idDireccion {get;set;}
    }

    /*public class Oportunidad
    {
        public String identificador {get;set;} // identificador de la oportunidad
        public String nombre {get;set;}
        public List<Oferta> ofertas {get;set;}

        public Oportunidad(String pId, String pNombre, List<Oferta> pListaofertas)
        {
            this.identificador = (pId == null ? '' : pId);
            this.nombre = (pNombre == null ? '' : pNombre);
            if(pListaofertas == null)
            {
                this.ofertas = new List<Oferta>();
            }
            else
            {
                this.ofertas = new List<Oferta>(pListaofertas);
            }
        }
    }*/

    public class Oferta
    {
        public String identificador {get;set;} // identificador de la oferta
        public String numPresupuesto {get;set;}
        public String tipo {get;set;} // tipo de la oferta
        public String fechaCreacion {get;set;} // formato yyyyMMdd
        public String fechaVigencia {get;set;} // formato yyyyMMdd
        public String duracionAnyos {get;set;} // duración anyos 
        public String estado {get;set;} // estado actual de la oferta: completa, enviada...
        public String observaciones {get;set;} // observaciones añadidas en el envío de la oferta
        public String enviarEmail {get;set;}
        public String emailDestinatario {get;set;}
        public String resolucionAnticipada {get;set;}
        public EquiposInstalarPrimagas equiposInstalarPrimagas {get;set;}
        public Prioridades prioridades {get;set;}
        public AhorroEstimado ahorroEstimado {get;set;}
        public Instalacion instalacion {get;set;}
        public Modular modular {get;set;}
        public Ajuste personalizada {get;set;}
        public Estandar estandar {get;set;}
        public String aplicarTramoEscalado {get;set;} // id de salesforce de tramo de tipo escalado, solo para oferta personalizada
        public String notas {get;set;} // notas para mostrar en la aplicación

        public Oferta(String pId)
        {
            this.identificador = (pId == null ? '' : pId);
            this.numPresupuesto = '';
            this.tipo = '';
            this.fechaVigencia = '';
            this.fechaCreacion = '';
            this.duracionAnyos = '';
            this.estado = '';
            this.observaciones = '';
            this.enviarEmail = '';
            this.emailDestinatario = '';
            this.resolucionAnticipada = '';
            this.equiposInstalarPrimagas = new EquiposInstalarPrimagas('');
            this.prioridades = new Prioridades();
            this.ahorroEstimado = new AhorroEstimado('','','');
            this.instalacion = new Instalacion();
            this.modular = new Modular();
            this.personalizada = new Ajuste();
            this.estandar = new Estandar();
            this.aplicarTramoEscalado = '';
            this.notas = '';
        }
    }

    public class EquiposInstalarPrimagas
    {
        public String equipos {get;set;}

        public EquiposInstalarPrimagas(String pEquip)
        {
            this.equipos = (pEquip == null ? '' : pEquip);
        }
    }

    public class Prioridades
    {
        public String comodidad {get;set;} // el cliente pregunta sobre la comodidad
        public String despreocuparse {get;set;} // el cliente pregunta sobre la telemedida
        public String enterrado {get;set;} // el cliente pregunta sobre el depósito enterrado
        public String ahorroAnual {get;set;} // el cliente pregunta sobre el ahorro al año
        public String precioRegulado {get;set;} // el cliente pregunta sobre si el precio está regulado
        public String pagarConsumo {get;set;} // el cliente pregunta sobre el pago por consumo
        public String precioFijo {get;set;} // el cliente pregunta sobre pagar un precio fijo
        public String tarifaPlana {get;set;} // el cliente pregunta sobre una tarifa plana mensual
        public String impacto {get;set;}  // impacto sobre el gasto en el gas en la economía del cliente

        public Prioridades()
        {
            this.comodidad = '';
            this.despreocuparse = '';
            this.enterrado = '';
            this.ahorroAnual = '';
            this.precioRegulado = '';
            this.pagarConsumo = '';
            this.precioFijo = '';
            this.tarifaPlana = '';
            this.impacto = '';
        }
    }

    public class AhorroEstimado
    {
        public String total {get;set;}
        public String totalPrimagas {get;set;}
        public String diferencia {get;set;}

        public AhorroEstimado(String pTotal, String pTotalPrimagas, String pDiferencia)
        {
            this.total = (pTotal == null ? '' : pTotal);
            this.totalPrimagas = (pTotalPrimagas == null ? '' : pTotalPrimagas);
            this.diferencia = (pDiferencia == null ? '' : pDiferencia);
        }
    }

    public class Instalacion
    {
        public List<Equipo> equipos {get;set;}
        public List<Energia> energias {get;set;}
        public Total total {get;set;}

        public Instalacion()
        {
            this.equipos = new List<Equipo>();
            this.energias = new List<Energia>();
            this.total = new Total();
        }
    }

    public class Equipo
    {
        public String idSalesforce {get;set;}
        public String nombre {get;set;} // nombre del equipo susceptible a instalar
        public String cantidad {get;set;}// cantidad de equipos susceptibles a instalar
        public String uso {get;set;} // en qué se utiliza el equipo
        public String potenciaKW {get;set;} // dato de la potencia del equipo
        public String antiguedad {get;set;} // año del equipo
        public String energia {get;set;} //energía del equipo

        public Equipo()
        {
            this.idSalesforce = '';
            this.nombre = '';
            this.cantidad = '';
            this.uso = '';
            this.potenciaKW = '';
            this.antiguedad = '';
            this.energia = '';
        }
    }

    public class Energia
    {
        public String idSalesforce {get;set;}
        public String nombre {get;set;} // nombre de la energía
        public String consumo {get;set;} // dato del consumo 
        public String consumoKWH {get;set;} // dato del consumo en KWh
        public String consumoKgCO2 {get;set;} // dato del consumo en kg CO2
        public String consumoL_primagas {get;set;} // dato del consumo con primagas en litros
        public String consumoKWH_primagas {get;set;} // dato del consumo con primagas en KWh
        public String consumoKg_primagas {get;set;} // dato del consumo con primagas en Kg
        public String consumoKgCO2_primagas {get;set;} // dato del consumo con primagas en kg CO2
        public String unidadConsumo {get;set;} // unidad de consumo seleccionada
        public String precio {get;set;} // dato del precio de la energía
        public String unidadPrecio {get;set;} // unidad del precio seleccionada
        public String proveedor {get;set;} // proveedor actual de esa energía
        public String rendimiento {get;set;} // dato de rendimiento seleccionado
        public String cambio {get;set;} // valor de cambio seleccionado
        public String importeSituacionActual {get;set;}

        public Energia()
        {
            this.idSalesforce = '';
            this.nombre = '';
            this.consumo = '';
            this.consumoKWH = '';
            this.consumoKgCO2 = '';
            this.consumoL_primagas = '';
            this.consumoKWH_primagas = '';
            this.consumoKg_primagas = '';
            this.consumoKgCO2_primagas = '';
            this.unidadConsumo = '';
            this.proveedor = '';
            this.rendimiento = '';
            this.cambio = '';
            this.importeSituacionActual = '';
            this.unidadPrecio = '';
            this.precio = '';
        }
    }

    public class Total
    {
        public String kg {get;set;} // total del consumo de todas las energías en kg
        public String kwh {get;set;} // total del consumo de todas las energías en KWh
        public String litros {get;set;} // total del consumo de todas las energías en litros
        public String kgCO2 {get;set;} // total del consumo de todas las energías en Kg CO2
        public String diferenciaKwh {get;set;} // valor en % de la diferencia en kWh entre la situación actual y el consumo
        public String diferenciaKgCo2 {get;set;} // valor en % de la diferencia en kg CO2 entre la situación actual y el consumo
        public String totalKgCO2Primagas {get;set;}
        public String totalKwhPrimagas {get;set;}

        public Total()
        {
            this.kg = '';
            this.kwh = '';
            this.litros = '';
            this.kgCO2 = '';
            this.diferenciaKwh = '';
            this.diferenciaKgCo2 = '';
            this.totalKgCO2Primagas = '';
            this.totalKwhPrimagas = '';
        }
        public Total(String pKg, String pKWh, String pLitros, String pKgCO2, String pDiferenciakwh, String pDiferenciakgCo2, String pKwhPrimagas, String pKgCO2Primagas)
        {
            this.kg = (pKg == null ? '' : pKg);
            this.kwh = (pKWh == null ? '' : pKWh);
            this.litros = (pLitros == null ? '' :pLitros);
            this.kgCO2 = (pKgCO2 == null ? '' :pKgCO2);
            this.diferenciaKwh = (pDiferenciakwh == null ? '' :pDiferenciakwh);
            this.diferenciaKgCo2 = (pDiferenciakgCo2 == null ? '' :pDiferenciakgCo2);
            this.totalKgCO2Primagas = (pKgCO2Primagas == null ? '' :pKgCO2Primagas);
            this.totalKwhPrimagas = (pKwhPrimagas == null ? '' :pKwhPrimagas);
        }
    }

    public class Modular
    {
        public InstalacionModular instalacion {get;set;}
        public Pack pack {get;set;}
        public Producto producto {get;set;}
       
        //public Ajuste ajuste {get;set;}

        public Modular()
        {
            this.instalacion = new InstalacionModular();
            this.pack = new Pack();
            this.producto = new Producto();
            
            //this.ajuste = new Ajuste();
        }
        public Modular(InstalacionModular pInstalacion, Pack pPack, Producto pProducto)
        {
            if(pInstalacion == null)
                this.instalacion = new InstalacionModular();
            else
                this.instalacion = pInstalacion;
            if(pPack == null)
                this.pack = new Pack();
            else
                this.pack = pPack;
            if(pProducto == null)
                this.producto = new Producto();
            else
                this.producto = pProducto;
            //this.ajuste = pAjuste;
        }
    }

    public class InstalacionModular
    {
        public String equipoInterior {get;set;} // descripción del equipo
        public String costeEquipoInterior {get;set;} // coste
        public String interior {get;set;} // 0/1 0:no y 1:sí
        public String costeInterior {get;set;} // coste del depósito
        public String deposito {get;set;} // descripción del depósito
        public String costeDeposito {get;set;} // coste del depósito
        public String exterior {get;set;} // 0/1 0:no y 1:sí
        public String costeExterior {get;set;} // coste del depósito
        public String vallado {get;set;} // 0/1 0:no y 1: sí
        public String costeVallado {get;set;} // coste del vallado
        public String obraCivil {get;set;} // 0/1 0:no y 1:sí
        public String costeObraCivil {get;set;} // coste de la obra civil
        public String totalInversion {get;set;} // total inversión
        public String totalfinanciable {get;set;} // total financiable
        public String pagoInicial {get;set;}
        public String tipoInteres {get;set;} // id del tipo de interés
        public String instalacionInterior {get;set;} 
        public String costeInstalacionInterior {get;set;}
        public String costeProyectos {get;set;}
        public String proyectos {get;set;} // Proyecto o Memoria
        public String financiacionSeleccionada {get;set;}
        public String numeroCuotas {get;set;} // número de cuotas seleccionadas
        public String importeCuotas {get;set;} // importe en función de las cuotas seleccionadas
        public String importeDoceCuotas {get;set;} // valor de la cuota si la financiación es en 12 meses
        public String importeEnGasEurosL {get;set;} // valor de la financiación en gas en €/L
        public String importeEnGasEurosKg {get;set;} // valor de la financiación en gas en €/Kg
        public String importeAhorroInstalacion {get;set;}
        public String aplicaTramo {get;set;}
        public List<Tramo> tramos {get;set;}

        public InstalacionModular()
        {
            this.equipoInterior = '';
            this.costeEquipoInterior = '';
            this.interior = '';
            this.costeInterior = '';
            this.deposito = '';
            this.costeDeposito = '';
            this.exterior = '';
            this.costeExterior = '';
            this.vallado = '';
            this.costeVallado = '';
            this.obraCivil = '';
            this.costeObraCivil = '';
            this.totalInversion = '';
            this.totalfinanciable = '';
            this.pagoInicial = '';
            this.tipoInteres = '';
            this.instalacionInterior = '';
            this.costeInstalacionInterior = '';
            this.costeProyectos = '';
            this.proyectos = '';
            this.financiacionSeleccionada = '';
            this.numeroCuotas = ''; 
            this.importeCuotas = ''; 
            this.importeDoceCuotas = ''; 
            this.importeEnGasEurosL = ''; 
            this.importeEnGasEurosKg = ''; 
            this.importeAhorroInstalacion = ''; 
            this.aplicaTramo = ''; 
            this.tramos = new List<Tramo>(); 
        }
    }

    public class Tramo
    {
        public String idSalesforce {get;set;}
        public String tramo {get;set;} // nombre del tramo
        public String porcentajeDesde {get;set;} // valor inicial del tramo en porcentaje
        public String porcentajeHasta {get;set;} // valor final del tramo en porcentaje
        public String consumoDesdeL {get;set;} // valor inicial del tramo en litros/año
        public String consumoHastaL {get;set;} // valor final del tramo en litros/año
        public String consumoDesdeKg {get;set;} // valor inicial del tramo en kg/año
        public String consumoHastaKg {get;set;} // valor final del tramo en kg/año
        public String financiacionL {get;set;} // importe de la financiación en gas para ese tramo en €/L
        public String financiacionKg {get;set;} // importe de la financiación en gas para ese tramo en €/Kg
              
        public Tramo()
        {
            this.idSalesforce = '';
            this.tramo = '';
            this.porcentajeDesde = '';
            this.porcentajeHasta = '';
            this.consumoDesdeL = '';
            this.consumoDesdeKg = '';
            this.consumoHastaL = '';
            this.consumoHastaKg = '';
            this.financiacionKg = '';
            this.financiacionL = '';
        }
    }

    public class Pack
    {
        public String packSeleccionado {get;set;} // id pack seleccionado
        public String totalImporte {get;set;} // importe del pack
        public List<ServicioSeleccionado> serviciosSeleccionados {get;set;}

        public Pack()
        {
            this.packSeleccionado = '';
            this.totalImporte = '';
            this.serviciosSeleccionados = new List<ServicioSeleccionado>();
        }
    }

    public class ServicioSeleccionado
    {
        public String idServicio {get;set;} // id salesforce del servicio seleccionado [de la tabla de maestros]
        
        public ServicioSeleccionado(String pId)
        {
            this.idServicio = (pId == null ? '' : pId);
        }
    }

    public class Producto
    {
        public String precioMensualL {get;set;} // valor producto de gas para la opción de precio mensual en litros
        public String precioFijoAnualL {get;set;} // vaor producto de gas para la opción de precio fijo anual en litros
        public String contadorL {get;set;} // valor producto de gas para la opción de contador en litros
        public String tarifaPlanaL {get;set;} // valor producto de gas para la opción de tarifa plana en litros
        public String precioMensualKg {get;set;} // valor producto de gas para la opión de precio mensual en kg
        public String precioFijoAnualKg {get;set;} // valor producto de gas para la opción de precio aual en kg
        public String contadorKg {get;set;} // valor producto de gas para la opción de contador en kg
        public String tarifaPlanaKg {get;set;} // valor producto de gas para la opción de tarifa plana en kg
        public String nivelPB {get;set;} // rango seleccionado del nivel PB
        public String fecha {get;set;} // fecha con formato yyyyMMdd
        public String opcionSeleccionada {get;set;} // 'mensual', 'fijo,', 'contador', 'plana'
        public String importeAhorroGas {get;set;} // importe
        
        //gserrano 12/12/2018
        public String clv5 {get;set;}
        public String clv10 {get;set;}
        public String gp {get;set;}

        public Producto()
        {
            this.precioMensualL = '';
            this.precioFijoAnualL = '';
            this.contadorL = '';
            this.tarifaPlanaL = '';
            this.precioMensualKg = '';
            this.precioFijoAnualKg = '';
            this.contadorKg = '';
            this.tarifaPlanaKg = '';
            this.nivelPB = '';
            this.fecha = '';
            this.opcionSeleccionada = '';
            this.importeAhorroGas = '';
            
            //gserrano 12/12/2018
            this.clv5 = '';
            this.clv10 = '';  
            this.gp = '';
        }
    }

    public class Ajuste
    {
        public List<Deposito> depositos {get;set;}
        public List<EquipoAjuste> equiposAjuste {get;set;}
        public PagoInversion pagoInversion {get;set;}
        public ProductoGas productoGasAjuste {get;set;}
        public PrimaServicios primaServiciosAjuste {get;set;}
        public List<Escalado> escalado {get;set;}

        public Ajuste()
        {
            this.depositos = new List<Deposito>();
            this.equiposAjuste = new List<EquipoAjuste>();
            this.pagoInversion = new PagoInversion();
            this.productoGasAjuste = new ProductoGas();
            this.primaServiciosAjuste = new PrimaServicios();
            this.escalado = new List<Escalado>();
        }
        public Ajuste(List<Deposito> pListaDepositos, List<EquipoAjuste> pEquiposAjuste, PagoInversion pPagoInv, ProductoGas pProdGas, PrimaServicios pPrimaServ, List<Escalado> pListaEscalado)
        {
            if(pListaDepositos == null)
                this.depositos = new List<Deposito>();
            else
                this.depositos = new List<Deposito>(pListaDepositos);
            if(pEquiposAjuste == null)
                this.equiposAjuste = new List<EquipoAjuste>();
            else
                this.equiposAjuste = new List<EquipoAjuste>(pEquiposAjuste);
            if(pPagoInv == null)
                this.pagoInversion = new PagoInversion();
            else
                this.pagoInversion = pPagoInv;
            if(pProdGas == null)
                this.productoGasAjuste = new ProductoGas();
            else
                this.productoGasAjuste = pProdGas;
            if(pPrimaServ == null)
                this.primaServiciosAjuste = new PrimaServicios();
            else
                this.primaServiciosAjuste = pPrimaServ;
            if(pListaEscalado == null)
                this.escalado = new List<Escalado>();
            else
                this.escalado = new List<Escalado>(pListaEscalado);
        }
    }

    public class Deposito
    {
        public String idSalesforce {get;set;}
        public String tipo {get;set;} // nombre del depósito
        public String cantidad {get;set;} // número de depósitos
        public String equiposExterior {get;set;} // importe 
        public String instalacionExterior {get;set;} 
        public String proyectos {get;set;} // importe 
        public String obraCivilVallado {get;set;} // importe 
        
        public Deposito()
        {
            this.idSalesforce = '';
            this.tipo = '';
            this.cantidad = '';
            this.equiposExterior = '';
            this.instalacionExterior = '';
            this.proyectos = '';
            this.obraCivilVallado = '';
        }
    }

    public class EquipoAjuste
    {
        public String idSalesforce {get;set;}
        public String nombre {get;set;}
        public String cantidad {get;set;}
        public String equiposExterior {get;set;}
        public String instalacionExterior {get;set;}
        public String equiposInterior {get;set;}
        public String instalacionInterior {get;set;}

        public EquipoAjuste()
        {
            this.idSalesforce = '';
            this.nombre = '';
            this.cantidad = '';
            this.equiposExterior = ''; 
            this.instalacionExterior = '';
            this.equiposInterior = '';
            this.instalacionInterior = '';
        }
    }

    public class PagoInversion
    {
        public String tipo {get;set;} // nombre de la tarifa
        public String pagoIncial {get;set;} // importe 
        public String cuotaInversion {get;set;} // importe
        public String duracionCuota {get;set;} 
        public String dto1llenado {get;set;}

        public PagoInversion()
        {
            this.tipo = '';
            this.pagoIncial = '';
            this.cuotaInversion = '';
            this.duracionCuota = '';
            this.dto1llenado = '';
        }
    }

    public class ProductoGas
    {
        public String tipo {get;set;}
        public String tarifa {get; set;}
        public String dto {get;set;}
        public String duracionDto {get;set;}
        public String precio {get;set;}

        public ProductoGas()
        {
            this.tipo = '';
            this.tarifa = '';
            this.dto = '';
            this.duracionDto = '';
            this.precio = '';
        }
    }

    public class PrimaServicios
    {
        public String tipo {get;set;}
        public String tarifa {get; set;}
        public String mto {get;set;}
        public String inspeccionInterior {get;set;}
        public String revisionInterior {get;set;}
        public String precio {get;set;}

        public PrimaServicios()
        {
            this.tipo = '';
            this.tarifa = '';
            this.mto = '';
            this.inspeccionInterior = '';
            this.revisionInterior = '';
            this.precio = '';
        }
    }

    public class Escalado
    {
        public String idSalesforce {get;set;}
        public String tramo {get;set;} // nombre del tramo
        public String porcentajeDesde {get;set;} // valor inicial del tramo en porcentaje
        public String porcentajeHasta {get;set;} // valor final del tramo en porcentaje
        public String consumoDesdeL {get;set;} // valor inicial del tramo en litros/año
        public String consumoHastaL {get;set;} // valor final del tramo en litros/año
        public String consumoDesdeKg {get;set;} // valor inicial del tramo en kg/año
        public String consumoHastaKg {get;set;} // valor final del tramo en kg/año
        public String dtoL {get;set;} // valor a descontar en litros
        public String dtoKg {get;set;} // valor a descontar en kg
        public String duracionDTO {get;set;} // duración del descuento
        public String precioHoyL {get;set;} // precio HOY en litros
        public String precioHoyK {get;set;} // precio HOY en kg
        public String primaServiciosA {get;set;} // importe del servicio seleccionado para 12 meses
        public String pba {get;set;} // valor del PBA
        
        //gserrano 12/12/2018
        public String clv5 {get;set;}
        public String clv10 {get;set;}
        public String gp {get;set;}

        public Escalado()
        {
            this.idSalesforce = '';
            this.tramo = '';
            this.porcentajeDesde = '';
            this.porcentajeHasta = '';
            this.consumoDesdeL = '';
            this.consumoHastaL = '';
            this.consumoDesdeKg = '';
            this.consumoHastaKg = '';
            this.dtoL = '';
            this.dtoKg = '';
            this.duracionDTO = '';
            this.precioHoyL = '';
            this.precioHoyK = '';
            this.primaServiciosA = '';
            this.pba = '';
            
            //gserrano 12/12/2018
            this.clv5 = '';
            this.clv10 = '';  
            this.gp = '';
        }
    }

    public class Estandar
    {
        public String tipoOferta {get;set;} // nombre de la oferta seleccionada
        public String interior {get;set;} // opción de interior seleccionada
        public String exterior {get;set;} // opción de exterior seleccionada
        public String servicio {get;set;} // opción de servicio seleccionada
        public String consumoContratado {get;set;} // unificado en l y kg 
        public String texto {get;set;} // texto opción de servicio seleccionada
        public String tarifa {get;set;} // valor de la tarifa
        public String dto {get;set;} // valor decimal
        public String duracionDto {get;set;}
        public String pagoInicial {get;set;} // ìmporte
        public String precioFecha {get;set;} 
        public String precioL {get;set;} // valor del precio en litros
        public String precioKg {get;set;} // valor del precio en kg
        public String servicioValor {get;set;} // valor del servicio
        public String idSalesforce {get;set;} //id del registro de la tabla maestra "OpcionesOfertaSTD"
        public String idSalesforceTipoOferta {get;set;} //id del registro de la tabla maestra "ImagenesOferta"

        public Estandar()
        {
            this.tipoOferta = '';
            this.interior = '';
            this.exterior = '';
            this.servicio = '';
            this.consumoContratado = '';
            this.texto = '';
            this.tarifa = '';
            this.dto = '';
            this.duracionDto = '';
            this.pagoInicial = '';
            this.precioFecha = '';
            this.precioL = '';
            this.precioKg = '';
            this.servicioValor = '';
            this.idSalesforce = '';
            this.idSalesforceTipoOferta = '';
        }
    }
}