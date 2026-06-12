#import "template.typ" : *


#show: it => basic-report(
  doc-category: "TB069 - Electromagnetismo Aplicado",
  doc-title: "Acopladores direccionales \nDiseño e implementación",
  author: "Rodriguez Guido E. (108723) - Duque Karla A. (108406)",
  affiliation: "FIUBA",
  logo: image("imgs/Logo-fiuba_big.png", width: 3cm),
  // <a href="https://www.flaticon.com/free-icons/aerospace" title="aerospace icons">Aerospace icons created by gravisio - Flaticon</a>
  language: "es",
  abstract: lorem(50),
  compact-mode: false,
  it
)

#set math.equation(numbering: "(1)")
#import "@preview/subpar:0.2.2"
#import "@preview/fancy-units:0.1.0": *
#import "@preview/simple-plot:0.3.0": plot
#import "@preview/booktabs:0.0.4": *
#show: booktabs-default-table-style


#set page(margin: (y:3cm,x:1in))
#show link: underline

#show <add_to_outline_without_numbering>:set heading(outlined: true,numbering: none)


#let todo(task) = {return text(size: 10pt,fill:red, upper[#task])}


#show figure: set text(size:9pt)


// #heading(outlined: false)[
  
// -----------------------------------------------------------
// AUX
// -----------------------------------------------------------
#let fn_open_stub(x) = return {-1.0 / calc.tan(x)}
#let fn_short_stub(x) = return {calc.tan(x)}

#let plot_z_stub_vs_l(is_open_stub:true,color_1,color_2,phase_offset) =[
    #let fn_stub = if is_open_stub == true{
        fn_open_stub
    } else {
        fn_short_stub
    }
   #plot(
    xmin: -2.0 * calc.pi, xmax: 2.0 * calc.pi - 0.1,
    ymin: -5.5, ymax:6,
    width: 6.5, height: 5,
    xlabel: $beta l$,
    ylabel: $Z(l)$,
    show-grid: "none",
    grid-label-break: false, // Defaul
    x-extend: (22, 2),
    axis-y-extend: (1, 1.5),
    show-origin: false,  // Avoid duplicate "0" with custom xtick-labels
    ytick: none,
  
    xtick: (-2.0*calc.pi,-3.0/2.0 * calc.pi,-calc.pi,-calc.pi/2,calc.pi/2, calc.pi,3/2*calc.pi, 2.0*calc.pi),
    xtick-labels: ($-2 pi$,$(- 3 pi)/2$ ,$- pi$,$- pi/2$ ,$pi/2$,$pi$, $(3 pi)/2$,$2 pi$),
    
    (fn: x => fn_stub(x), stroke: color_1.lighten(50%) + 1.2pt, samples: 175),
    (fn: x => fn_stub(x), domain:((-calc.pi + phase_offset - 0.01),(-calc.pi+ phase_offset + 0.0)),stroke: color_2 + 1.5pt, samples: 1),
    (fn: x => fn_stub(x), domain:((-0.00000001 + phase_offset),(0.01 + phase_offset)),stroke: color_2 + 1.5pt, samples: 1),
    (fn: x => fn_stub(x), domain:((calc.pi+ phase_offset - 0.09),(calc.pi + phase_offset + 0.0000001)),stroke: color_2 + 1.5pt, samples: 1),
  )
]


// Matriz de figuras

#let figures_matrix(description:"",port_name:"",
                    dir_coupler_name:"",
                    mag:"",pha:"",smith:"",dut:"",
                    offset_dut_pt:0pt,
                    offset_smith_pt:0pt,
                    cap_mag_opt:"",
                    cap_pha_opt:"",
                    cap_smith_opt:"",
                    cap_dut_opt:"",
                  ) = {
  let mag_caption = if cap_mag_opt.len() == 0 {
      [Magnitud (dB) del parámetro de reflexión ($S_(11)$) y transmisión ($S_(21)$) del puerto "#port_name"]
  } else{
      [#cap_mag_opt]
  }

  let pha_caption = if cap_pha_opt.len() == 0 {
      [Fase ($degree$) del parámetro de reflexión ($S_(11)$) y transmisión ($S_(21)$) del puerto "#port_name"]
  } else {
      [#cap_pha_opt]
  }

  let smith_caption = if cap_smith_opt.len() == 0 {
      [Carta de Smith del puerto "#port_name"]
  } else {
      [#cap_smith_opt]
  }

  let dut_caption = if cap_dut_opt.len() == 0 {
      [_Setup_ para medición del puerto "#port_name" del _DUT_]
  } else {
      [#cap_dut_opt]
  }

  let h_smith_alt = if offset_smith_pt == 0pt {
    160pt
  } else{
    auto
  }
                    
  show figure : set text(size:7pt)
  align(center+horizon)[
  #scale(reflow: false, x: 117%,y:135%)[
    #rotate(-90deg)[
      #subpar.grid(
        [
          
          #figure(image(mag),caption: mag_caption)
          #eval("<fig:mag_"+port_name+"_"+dir_coupler_name+">", mode: "code")
        ],
        [
          #figure(
            box(clip: true, radius: 5pt,outset: -0pt,
              image(fit: "stretch",width: 128pt + offset_smith_pt,height: h_smith_alt , smith)
            ),
          // #figure(image(width: 125pt,height: 160pt,fit: "stretch",smith),
          caption: smith_caption)
          #eval("<fig:smith_"+port_name+"_"+dir_coupler_name+">", mode: "code")
        ],
        [
          #figure(image(pha),
          caption:pha_caption)
          #eval("<fig:pha_"+port_name+"_"+dir_coupler_name+">", mode: "code")
        ],
        [
          #figure(
            box(clip: true, radius: 5pt,outset: -0pt,
              image(fit: "stretch",width: 128pt + offset_dut_pt,dut)
            ),
          caption: dut_caption)
          #eval("<fig:bench_setup_"+port_name+"_"+dir_coupler_name+">", mode: "code")
        ],
        columns: (2fr,1fr),
        caption: [#description],
        gap: 0.5cm,
        gutter:0.45cm,
      )
    ]
  ]
]

}

// -----------------------------------------------------------










= Introducción general

== Contexto y motivación
En el marco de la asignatura _TB069 - Electromagnetismo Aplicado_ del plan 2023 de la carrera de Ingeniería Electrónica, se presenta la posibilidad de promoción mediante la realización de un trabajo práctico de aplicación por lo que a lo largo de esta memoria se presentará el proceso de diseño, implementación y medición de un acoplador direccional _microstrip_ para el cual de forma preliminar se caracterizará el sustrato sobre el cual será construido mediante tres métodos de medición indirecta los cuales se van a ver detalladamente mas adelante.  

== Objetivos y alcances

En el marco de la asignatura _TB069 - Electromagnetismo Aplicado_ del plan 2023 de la carrera de Ingeniería Electrónica, se presenta la posibilidad de promoción mediante la realización de un trabajo práctico de aplicación por lo que a lo largo de este informe se procederá a diseñar e implementar un acoplador direccional para el cual previamente se realizará la caracterización del sustrato mediante tres métodos diferentes de medición indirecta: $Delta S$ (diferencia de fase), resonador de anillo y Capacitancia.
  
Como parte de la actividad del club de radio frecuencia de la facultad, siendo ambos miembros activos del mismo, se presenta la idea de desarrollar un adaptador automático de antena con el fin de estudiar su proceso de diseño y posterior implementación, para ello se determinó la necesidad de diseñar e implementar un *acoplador direccional* del cual se obtendrá el parámetro de reflexión mediante el circuito integrado AD8302, el circuito de control basado en el uso de un microcontrolador y finalmente el circuito de adaptación. De forma paralela se decide *caracterizar el sustrato* con el fin de determinar de forma fehaciente su permitividad relativa ($epsilon_r$) y su $tg(delta)$ logrando así minimizar la discrepancia entre los resultados teóricos y experimentales. 

A continuación se presenta un diagrama de bloques de la relación de las diferentes etapas y actividades del proyecto.

#figure(  
  image("imgs/esquema_de_trabajo.png",width: 80%)
)


Luego de una primer conversación con el Dr. Ing Gustavo Fano, se decidió tomar una parte acotada del proyecto para ser presentado como propuesta de realización con los siguientes bloques:
- Diseño, simulación e implementación del acoplador direccional incluyendo un marco teórico introductorio y consideraciones prácticas tenidas en cuenta
- Caracterización del sustrato mediante la medición 
- Diseño e implementación de una interfaz gráfica que permita caracterizar el sustrato

= Introducción específica
A continuación se explicarán algunos conceptos necesarios para llevar a cabo la elaboración del acoplador direccional como así también los métodos de medición empleados.


== Líneas de transmisión

Una línea de transmisión es un medio físico que transporta energía eléctrica o información desde un punto a otro, mediante conductores metálicos. Se utiliza cuando las dimensiones físicas del sistema son comparables con la longitud de onda de la señal, de modo que los efectos de propagación no pueden ser despreciados.

=== Modelo de la línea de transmisión de parámetros concentrados

El análisis de una línea de transmisión puede realizarse mediante un modelo equivalente de parámetros concentrados, en el cual se representan los distintos fenómenos físicos asociados a la propagación de la señal:

La *Resistencia (R)* para modelar las pérdidas en los conductores, la *Inductancia (L)* para representar la energía magnética, la  *Capacitancia (C)* para representar la energía eléctrica, y la *Conductancia (G)* para modelar las pérdidas debidas al dieléctrico.

Estos parámetros están definidos por unidad de longitud y dependen tanto de la geometría de la línea como de las propiedades eléctricas de los materiales que la componen. El conjunto de los cuatro parámetros recibe el nombre de modelo RLGC, y constituye la base para la formulación de las ecuaciones de la línea de transmisión.


#figure(
image("imgs/ilustrations/rlgc.svg", width: 65%),
caption: [Modelo RLGC de una linea de transmisión]
)

Aplicando las leyes de Kirchhoff a un segmento infinitesimal $Delta l$,  se obtienen la @ec_tension y @ec_corriente, las denominadas ecuaciones del telegrafista , que describen la variación espacial de la tensión y la corriente:
  


  #grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ (d V(l))/(d l) = - (R + J omega L) dot Delta_l dot I(l) $<ec_tension>],
  [$ (d I(l))/(d l) = -(G + j omega C) dot Delta_l dot V(l)) $<ec_corriente>]           // Segunda ecuación
)


Estas ecuaciones diferenciales de primer orden son la base  para obtener una ecuación diferencial de segundo orden para la tensión y otra para la corriente, conocida como ecuación de Helmholtz (@ec:Helmholtz_tension y @ec:Helmholtz_corriente), que describe la propagación de ondas a lo largo de la línea:


  #grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ (d² V(l))/(d² l) - gamma^2 dot V (l) = 0 $<ec:Helmholtz_tension>],
  [$ (d² I(l))/(d² l) - gamma^2 dot I (l) = 0 $<ec:Helmholtz_corriente>],
)


Siendo $gamma$ es la constante de propagación de la linea que también se puede expresar tanto como la @gamma_parametros_concentrados como la @ec:cons_prop

 #grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ gamma = sqrt((j omega L + R) dot (j omega C + G))  
  $<gamma_parametros_concentrados>],
  [$ gamma = alpha + j beta $<ec:cons_prop>],
)


donde $alpha$ es la constante de atenuación, que representa la pérdida de amplitud de la señal a lo largo de la línea y $beta$ es la constante de fase, que describe la variación de fase de la onda durante su propagación.


Por consiguinte la solución general de la ecuación de Helmholtz conduce a las expresiones de la tensión (@ec:Tension_TL) y la corriente (@ec:Corriente_TL) a lo largo de la línea de transmisión:

 #grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ V(l) = V⁺ dot exp(- gamma l) + V⁻ dot exp(gamma l) $ <ec:Tension_TL>],
  [$ I(l) = I⁺ dot exp(- gamma l) + I⁻ dot exp(gamma l) $ <ec:Corriente_TL>],
)

Donde 𝑉⁺ e I⁺ representan las ondas incidentes que se propagan en el sentido positivo de la línea,mientras que 𝑉⁻ e 𝐼⁻ representan las ondas reflejadas que se propagan en sentido contrario.

=== Propagación de la señal en una linea de transmisión

La onda electromagnética en una linea de transmisión, se propaga principalmente en el material dieléctrico que separa ambas placas conductoras, es decir lo hace en un medio material.

La onda electromagnética que se propaga a lo largo de una línea de transmisión puede hacerlo mediante distintos modos de propagación, los cuales describen la orientación de los campos eléctrico y magnético con respecto a la dirección de propagación de la onda. Dependiendo de esta orientación, los campos pueden presentar componentes transversales, longitudinales o una combinación de ambas.

#v(-0.5cm)
#figure(
  image("imgs/modoTEMvectores.PNG", width: 5cm),
  caption: [Modo de propagación TEM]
)<fig:modo_tem>

Cuando el campo eléctrico y magnético son completamente transversales a la dirección de propagación, se presenta el modo TEM (Transversal Electromagnético) como se ilustra en la @fig:modo_tem, este modo ocurre en estructuras homogéneas como puede se striplines.

También existe el modo TE (Transversal Eléctrico), en el cual el campo eléctrico es completamente transversal a la dirección de propagación, mientras que el campo magnético presenta una componente longitudinal, caso contrario el modo TM (Transversal Magnético) el campo magnético es transversal a la propagación, y el campo eléctrico es quien presenta una componente longitudinal, ambos se ilustran en la @fig:TE y en la @fig:TM respectivamente.

#v(-0.25cm)
#subpar.grid(
  figure(image("imgs/modoTEvectores.PNG",width: 4.5cm), caption: [
   Modo de propagación TE
  ]), <fig:TE>,
  figure(image("imgs/modoTMvectores.PNG",width: 4.5cm), caption: [
    Modo de propagación TM
  ]), <fig:TM>,
  columns: (1fr, 1fr),
  gap: 0.5cm,
  gutter: 1cm, 
  caption: [Modo de propagación transversales],
  label: <fig_modo_propagacion>,
)


// Por otro lado, cuando los campos presentan componentes longitudinales significativas, se habla de modos no TEM.
Por otro lado, en muchas líneas de transmisión prácticas aparece el denominado modo cuasi-TEM, el cual es una aproximación de propagación de onda en líneas de transmisión donde los campos eléctrico y magnético son casi, pero no exactamente, perpendiculares a la dirección de propagación. Ocurre en estructuras inhomogéneas, como líneas de microstrip, debido a diferencias en la permitividad del dieléctrico (aire y sustrato) del cual luego ahondaremos en detalle 

Con el objetivo de simplificar el análisis y facilitar los cálculos, se asume que la onda se propaga cuasi-TEM, hipótesis válida para muchas líneas de transmisión utilizadas en la práctica.


=== Tipos de linea de transmisión
  Existen varios tipos de línea de transmisión que explicaremos a continuación:
  - Línea de transmisión sin pérdidas: Esto ocurre cuando el conductor y el dieléctrico son perfectos, es decir, es decir $R=0$ y $G=0$ del modelo RLGC antes mencionado.

  - Líneas de transmisión largas: Son aquellas líneas de transmisión que se pueden considerar infinitas para el entorno de análisis escogido, es decir si consideramos que en un entorno la línea es como infinita no existen las reflexiones por el cual todo se llega a transmitir.
  - Línea de transmisión sin distorsión: Es aquella en la que la señal de salida es una réplica exacta de la entrada, atenuada o retrasada, pero sin alterar su forma original. 
    
    Como condición para que una línea de transmisión sea sin distorsión debe cumplirse la @ec:TL_sin_distorsion por lo que la velocidad de propagación y la atenuación no dependen de la frecuencia.

  $ R/L = G/C $<ec:TL_sin_distorsion>

  - Línea de transmisión de baja resistencia: Es aquella en el que el conductor es perfecto, es decir,  no tiene perdidas por el conductor.
  
    Aqui podemos observar que  :

  #grid(
  columns: (1fr, 1fr), 
  column-gutter: 8pt, 
  $ L dot C = mu dot  epsilon $,  
  $ sigma/epsilon = G/C  $       
)
    
  En particular en este trabajo vamos a ver líneas de transmisión eléctricas tales como:
  
==== Líneas de transmisión de microcinta o _microstrip_ 

Es una línea de transmisión utilizada en PCB (circuitos impresos), consiste en una pista (linea de transmisión) sobre el sustrato dieléctrico con un plano de tierra inferior, tal como indica la @fig:microstrip.

#v(-0.6cm)
#figure(
image("imgs/ilustrations/microstripDespliegue.png", width: 40%),
caption: [Microstrip] 
)<fig:microstrip>


Cabe destacar que la estructura, al estar inmersa entre los dos materiales, la señal se propaga tanto por el dieléctrico como por el aire. Esta discontinuidad de medios provoca que el campo electromagnético no sea puramente transversal, dando lugar al modo cuasi-TEM antes mencionado. Asimismo, aparecen las pérdidas por radiación, ya que una fracción de la energía no queda confinada en el sustrato sino que se radia.

Un parametro importante que debemos mencionar es permitividad electrica efectiva, esta expresion es consecuencia natural de la forma en la que se encuentra construida nuestra estructura al estar embebida entre dos medios materiales con permitividades electricas relativas diferentes, poniendo de manifiesto que la onda propagante percibirá un permitividad electrica relativa equivalente que se encontrará entre $epsilon_r$ del aire (1) y $epsilon_r$  del sustrato.

// #todo("REVISAR")
 
La velocidad de fase se expresa como  $v_p = c_0/ sqrt(epsilon_(e f f))$

Siendo $c_0$ la velocidad de la luz en el vacío y $lambda$ la longitud de onda.


  
==== Líneas de transmisión stripline 
  
  Stripline es una línea de transmisión formada por tres conductores. asi como se observa en la @fig:stripline, los conductores de los planos superior e inferior son planos de tierra, y la banda conductora central se encuentra entre los dos dieléctricos. El espacio entre la banda conductora y los planos de tierra puede ser aire u otros materiales dieléctricos.

  #v(-0.5cm)
  #figure(
    image("imgs/ilustrations/striplineDespliegue.png", width: 40%),
    caption: [Línea de transmisión Stripline] 
  )<fig:stripline>

  Estas lineas tienen como ventaja que evita las interferencias radiadas (la radiación es mínima y puede despreciarse), con una pérdida similar a la de las líneas coaxiales. Sin embargo, como el $epsilon_(e f f)$ que es igual al $epsilon_r$, es mayor que el de una microstrip debido a que la propagación se produce solo en el sustrato. Esto reduce la velocidad de fase de la señal, resultando una longitud de onda ($lambda$) mas corta para una misma frecuencia.


== Materiales

El material que se utilizo en este trabajo es el FR4, uno de los materiales dieléctricos más utilizados en la fabricación de placas de circuito impreso (PCB). Este material está compuesto por un tejido de fibra de vidrio con un entretramado de malla como se observa en la @fig:malla_fr4 impregnado con resina epoxi, dispuesto en forma de múltiples capas superpuestas (stack), sobre las cuales se laminan las capas de cobre que conforman las pistas conductoras del circuito.

#figure(
image("imgs/ilustrations/Malla_FR4_MBE.PNG", width: 45%),
caption: [Tejido de malla de sustrato FR4 estilo 1080]
)<fig:malla_fr4>

Las siglas FR provienen del término Flame Retardant (retardante de llama), mientras que el número 4 corresponde a una clasificación específica dentro de esta familia de materiales. Esta propiedad se debe principalmente a la composición de la resina epoxi utilizada, la cual permite retardar la propagación del fuego en caso de exposición a altas temperaturas.

Desde el punto de vista eléctrico, el FR4 se caracteriza por su permitividad relativa ( $epsilon_r$) y su tangente de pérdidas (tan $delta$), parámetros que describen el comportamiento del material frente a campos eléctricos alternos. La tangente de pérdidas cuantifica la energía disipada en el dieléctrico debido a los procesos de polarización del material. Valores bajos de este parámetro indican menores pérdidas y, por lo tanto, una mejor propagación de las señales electromagnéticas.


#subpar.grid(
  figure(image("imgs/ilustrations/dielectricoNoPolTAND.PNG",width: 100%), caption: [
    PCB no polarizado
  ]), <fig:di_no_pol>,
  figure(image("imgs/ilustrations/dielectricoSIPolTAND.PNG",width: 100%), caption: [
   PCB polarizado
  ]), <fig:di_pol>,
  columns: (1fr, 1fr),
  gap:0.5cm,
  gutter:2cm,
  caption: [Polarización del sustrato del PCB],
  label: <fig:polarizacion_dielectrico>,
)

En la práctica, el sustrato FR4 no es perfectamente homogéneo ni isotrópico, debido principalmente a la estructura del tejido de fibra de vidrio y a imperfecciones propias del proceso de fabricación. Estas variaciones pueden generar pequeñas diferencias en la permitividad efectiva del material, afectando parámetros importantes en el diseño de líneas de transmisión, como la impedancia característica y la velocidad de propagación.

Asimismo, la rugosidad de las capas de cobre puede incrementar las pérdidas por conducción, especialmente a frecuencias del orden de los GHz. A pesar de ello, cierta rugosidad es necesaria para asegurar una adecuada adhesión entre el cobre y el sustrato dieléctrico durante el proceso de fabricación del PCB.

A pesar de estas limitaciones, el FR4 es el material seleccionado para este trabajo debido a su bajo costo, amplia disponibilidad y facilidad de fabricación, lo que lo convierte en una opción adecuada para la implementación de estructuras de microstrip y para la caracterización experimental de parámetros dieléctricos. Si bien su naturaleza inhomogénea puede introducir pequeñas variaciones en los resultados,para la frecuencia de trabajo que es #qty[915][MHz] el material sigue siendo suficientemente adecuado para el análisis y validación de los métodos de caracterización propuestos.

=== Fuentes de referencia (links adjuntos) #todo("REVISAR ESTO")
// Caracterización del sustrato
// - #link("https://scikit-rf.readthedocs.io/en/latest/examples/networktheory/Correlating%20microstripline%20model%20to%20measurement.html")[Scikit-RF - Biblioteca de cálculo numérico para RF en pyhton]
// - #link("http://lamsimenterprises.com/Paper_APracticalMethodtoModelEffectivePermittivity_Simonovich.pdf")[_Paper_ sobre medición de la permitividad efectiva de línea microstrip]
// - #link("https://www.researchgate.net/publication/3056463_Wideband_frequency-domain_characterization_of_FR-4_and_time-domain_causality")[_Paper_ sobre el modelo utilizado como extensión sobre el modelo de Debye]
// - #link("https://engineering.sdsu.edu/engin/pubs/IEEE_MTT_DK_DF.pdf")[_Paper_ de nuevos métodos sobre el modelo de Debye para la medición de la permitividad efectiva]

// Acoplador direccional
// - #link("https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/Microwave_and_RF_Design_II_-_Transmission_Lines_(Steer)/05%3A_Coupled_Lines_and_Applications/5.08%3A_Directional_Coupler")[Introducción al diseño de acopladores direccionales]
// - #link("https://riunet.upv.es/server/api/core/bitstreams/e3ce079f-a01c-4f41-b2bd-8be1be4b73d0/content")[Teoría sobre acopladores direccionales]
// - #link("https://www.allaboutcircuits.com/technical-articles/an-introduction-to-directional-couplers-and-their-application-in-vector-network-analyzers/")[Más teoría introductoria]
// - #link("https://www.digikey.com/en/articles/the-fundamentals-of-rf-directional-couplers-and-how-to-use-them-effectively?utm_source=chatgpt.com")[Mediciones con acopladores direccionales]
// - #link("https://upcommons.upc.edu/server/api/core/bitstreams/cac75ff6-f9d3-44a0-bb7d-41c74aa24020/content")[Simulación electromagnética y acopladores direccionales]
// // - #link()

== Aplicaciones

En esta sección se presentan algunas aplicaciones prácticas de los conceptos desarrollados previamente sobre líneas de transmisión. Antes de analizar cada caso, se realizará una breve explicación teórica de cada estructura, con el objetivo de comprender su principio de funcionamiento.

En particular, se estudiarán dispositivos utilizados en circuitos de radiofrecuencia y microondas implementados sobre PCB, tales como los stubs, el resonador de anillo y el acoplador direccional.

=== Stubs 

Un stub es una línea de transmisión de longitud finita que normalmente se conecta a otra línea de transmisión principal y cuyo extremo puede terminar en circuito abierto o en cortocircuito. Debido a las propiedades de propagación de las líneas de transmisión, un stub presenta una impedancia de entrada dependiente de su longitud eléctrica, lo que permite utilizarlo como elemento reactivo en circuitos de radiofrecuencia.

#figure(
  image("imgs/ilustrations/stubs_dibujo.png", width: 45%),
  caption: [Stubs]
)<fig:stubs_dibujo>


Cuando el stub con terminación en circuito abierto $Z_L = infinity$, la impedancia del stub es:


$ Z(l)= -j dot Z_0 dot cot(beta dot l) $<ec:stub_abierto>

Por otro lado, cuando el stub con terminación en cortocircuito $Z_L= 0$, la impedancia es:

$ Z(l) = j dot Z_0 dot tan(beta dot l) $<ec:stub_corto>

#subpar.grid(
  figure(plot_z_stub_vs_l(navy,red,0,is_open_stub:true), caption: [Stub con terminación en circuito abierto]), <fig:open_stub>,
  figure(plot_z_stub_vs_l(navy,fuchsia ,calc.pi/2.0,is_open_stub: false), caption: [Stub con terminación en cortocircuito]), <fig:short_stub>, 
  columns: (1fr, 1fr),
  gap:0.5cm,
  gutter:-0cm,
  caption: [Impedancia del stub en función de $ beta l$],
)

Una de las aplicaciones más comunes es la adaptación de impedancias, donde el stub se emplea para compensar la parte reactiva de una carga y lograr una mejor transferencia de potencia entre la línea y el dispositivo conectado.


Además, los stubs también se utilizan en el diseño de filtros de microondas, donde actúan como elementos reactivos implementados directamente sobre el PCB. 

Otra aplicación relevante consiste en su uso para la caracterización de sustratos dieléctricos, ya que a partir de la frecuencia de resonancia de un stub es posible estimar la permitividad efectiva del sustrato sobre el cual se implementa la línea de transmisión. Esto resulta particularmente útil en el análisis y validación de materiales utilizados en circuitos de alta frecuencia.


Para cada stub se cumple:

  #grid(
  columns: (1fr, 1fr), 
  column-gutter: 8pt, 
  $ L_1 = n dot lambda_1/4 =(n dot c_0)/(4 dot f_1 dot sqrt(epsilon_(e f f)) ) $,          
  $ L_2 =n dot lambda_2/4 = (n dot c_0)/(4 dot f_2 dot sqrt(epsilon_(e f f))) $           
)

Donde $L_1$ y $L_2$ son las longitudes físicas de los stubs, $f_1$ y $f_2$ son sus respectivas frecuencias de resonancia, y $n$ es un número entero que corresponde al armónico del modo de resonancia analizado (el cual debe ser el mismo para ambos stubs).

Cabe destacar que en un stub con terminación en circuito abierto, las condiciones de resonancia se dan cuando $beta dot l = (2k + 1) pi / 2$. Como se puede observar en la @fig:open_stub , en estos valores la impedancia se anula y el stub se comporta como un cortocircuito hacia la línea principal, haciendo que las resonancias ocurran en los armónicos impares ($n = 1, 3, 5, ...$). 

Por el contrario, un stub con terminación en cortocircuito resuena cuando $beta dot l = k dot pi$ y $l = n dot lambda/4$. En la @fig:short_stub se aprecia que en estos puntos la impedancia también se hace cero. Bajo esta condición, su entrada se comporta como un cortocircuito, por lo que las resonancias aparecen en los armónicos pares ($n = 2, 4, 6, ...$).


Restando ambas expresiones se obtiene:
$ L_2- L_1 = (n dot c_0)/(4 dot sqrt(epsilon_(e f f))) dot (1/f_2- 1/f_1)  $

despejando el $epsilon_(e f f )$

$ epsilon_(e f f) = ((n dot c_0)/(4 dot (L_2-L_1)))^2 dot (1/f_2- 1/f_1)^2 $<ec:eff_stubs>

=== Anillos resonantes

Un resonador de anillo es una estructura formada por una línea de transmisión cerrada sobre sí misma, cuya longitud eléctrica permite la formación de condiciones de resonancia bien definidas. Este tipo de estructuras ha sido ampliamente utilizado en circuitos de microondas y radiofrecuencia.

#todo("REFERENCIAR LA TESIS DE BOGGI")

#figure(
  image("imgs/ilustrations/ring_resonator_dibujo.png", width: 50%),
  caption: [Esquema básico de un resonador de anillo]
)<fig:ring_dibujo>

El circuito básico de un resonador de anillo está compuesto por las líneas de alimentación (_feed_ _lines_), y el resonador propiamente dicho (anillo), como se ilustra en la @fig:ring_dibujo. Las líneas de alimentación permiten transferir potencia hacia el resonador y extraerla desde él. Dichas líneas se encuentran separadas del anillo por una distancia denominada _gap_.

La dimensión del _gap_ resulta crítica en el comportamiento del sistema: debe ser lo suficientemente grande para evitar el efecto capacitivo en el resonador, pero a la vez lo suficientemente pequeño para permitir una adecuada transferencia de energía. En estas condiciones, el mecanismo de interacción entre las líneas de alimentación y el resonador se clasifica como acoplamiento débil.

Cuando Troughton en 1969 empleó el resonador de anillo para la caracterización de estructuras _microstrip_, se baso en la aproximación de linea recta (_straight-line aproximation_ en función del radio medio) y asumió que la propagación en el anillo solo es posible para aquellas frecuencias en las cuales la longitud de la circunferencia media del resonador es igual a un múltiplo entero de la longitud de onda. Esta condición puede expresarse como:

$ L = n dot lambda $<ec:l_lambda>

donde $L$ es la longitud total del anillo, $n$ es un número entero correspondiente al modo de resonancia y $lambda$ es la longitud de onda en la línea de transmisión.

En el caso de un resonador circular de radio medio $R_(m e d)$, la longitud total del anillo corresponde a su perímetro medio:

$ L = 2 pi R_(m e d) $<ec:l_r>

Por otro lado, la longitud de onda se relaciona con la velocidad de la luz en el vacío ($c_0$) mediante la permitividad efectiva del sustrato ($epsilon_(e f f)$):

$ lambda = c_0 / (f dot sqrt(epsilon_(e f f))) $<ec:lambda>

Sustituyendo la @ec:lambda en la condición de resonancia (@ec:l_lambda), es posible obtener una expresión analítica para calcular la permitividad efectiva del sustrato a partir de la frecuencia de resonancia medida:

$ epsilon_(e f f) = ((n dot c_0) / (f dot L))^2 $<ec:eff_ring>

#todo("Modificar la redacción sobre el mode chart")

Sin embargo utilizando el paper de Wu y Rosenbaum en el que utilizan el _mode chart_ para resonadores de anillo, el cual es un gráfico que relaciona la frecuencia con la ratio entre el ancho del anillo y el radio medio ($f$ vs $w/R_(m e d)$), donde se puede observar los distintos modos de propagación. 

Estos modos se denominan modo $T M_(n m l)$, $T M$ por transversal magnetico definido anteriormente, n es la variación azimutal (alrededor del anillo), esta indica cuántas longitudes de onda completas entran a lo largo de la circunferencia del anillo, por ejemplo, si $n=1$ se transmite una longitud de onda al recorrer los 360 grados del anillo, la m es la variación radial, este indica cuantos... y el l indica la variación en altura de la onda, pero como el sustrato es tan delgado que el campo no varía en altura, casi siempre será un 0.

Para aplicaciones prácticas, se busca operar en el modo fundamental, típicamente el modo $T M_(110)$
, ya que presenta una distribución de campos más simple y una respuesta más predecible. Sin embargo, la excitación de modos superiores puede ocurrir dependiendo de la geometría del resonador, lo cual es necesario evitar ya que los modos superiores o modos de alto orden pueden generar resonancias intermedias por lo que la caracterización del sutrato no seria, este modelo no seria valido.



termina resultando que $w/R_(m e d) <= 1$, es decir un "anillo fino" para que el anillo no tenga modos de alto orden.

Además de la permitividad efectiva, el resonador de anillo permite caracterizar las pérdidas dieléctricas del sustrato, expresadas a través de la tangente de pérdidas ($tan delta$). Este parámetro resulta fundamental para definir la permitividad compleja del material, dada por $epsilon = epsilon' (1 - j tan delta)$.

Para extraer este parámetro se basa en el análisis del factor de calidad ($Q$) del modo resonante a partir de las mediciones experimentales del coeficiente de transmisión ($S_(21)$). Utilizando la frecuencia de resonancia ($f$) y el ancho de banda a -3 dB ($Delta f$), se calcula inicialmente el factor de calidad con carga ($Q_L$):

$ Q_L = f / (Delta f) $<ec:Q_carga>

Dado que el resonador se encuentra acoplado a las líneas de alimentación a través de los _gaps_, el valor de $Q_L$ incluye el efecto de carga del circuito. Para obtener el factor de calidad descargado ($Q_0$), que representa únicamente las pérdidas internas de la estructura, los modelos de Chang y Hsieh establecen que se debe compensar la pérdida de inserción en la resonancia. Para un anillo acoplado simétricamente, la relación es:

$ Q_0 = Q_L / (1 - 10^(-L/20)) $<ec:Q_sin_carga>

donde $L$ es la perdida de inserción en [dB] del anillo en la frecuencia de resonancia.

Las pérdidas totales en el resonador, representadas por la inversa del factor de calidad ($1/Q_0$), son la suma de las contribuciones individuales de las pérdidas en el dieléctrico ($1/Q_d$), las pérdidas en el conductor ($1/Q_c$) y las pérdidas por radiación ($1/Q_r$). De acuerdo con el análisis de estructuras _microstrip_ cerradas expuesto en la obra, las pérdidas por radiación pueden asumirse como despreciables ($1/Q_r approx 0$), por lo que el factor de calidad dieléctrico puede aislarse de la siguiente manera:

$ 1/Q_d = 1/Q_0 - 1/Q_c $<ec:q_dielectrico>

Finalmente, se demuestra que la tangente de pérdidas del sustrato está inversamente relacionada con el factor de calidad dieléctrico del resonador:

$ tan delta = 1 / Q_d $<ec:tan_delta>

Tener en cuenta que solo con este método de caracterización se puede obtener la $tan( delta)$ del sutrato.




==== Modelo de Parámetros Concentrados

Para complementar el análisis basado en modelos distribuidos, es necesario introducir un modelo de parámetros concentrados que capture los efectos de acoplamiento no ideales presentes en los gaps. Chang y Hsieh proponen un circuito equivalente riguroso para representar la interacción entre las líneas de alimentación y el anillo resonante.




#figure(
  image("imgs/modelo_concentrado_ring_resonator.png", width: 60%),
  caption: [Circuito de parametros concentrados para un resonador de anillo]
)<fig:ring_parametros_concentrados>


Tal como se observa en la @fig:ring_parametros_concentrados, el 
modelo se desglosa en dos secciones:

+ *Lineas de alimentación:* Las líneas de entrada y salida interactúan con el anillo a través de sendas $pi$-redes capacitivas formadas por los elementos $C_1$ y $C_2$. Estas capacitancias parásitas modelan los campos eléctricos acumulados en el *_gap_* del circuito abierto, permitiendo la transferencia de energía al anillo.
+ *Anillo:* El anillo propiamente dicho se representa mediante la red central en forma de rombo compuesta por las impedancias equivalentes $Z_a$ y $Z_b$. Físicamente, cuando la señal ingresa al anillo, se divide propagándose por dos caminos paralelos (las dos mitades de la circunferencia). Estas impedancias modelan el comportamiento de dichos trayectos, teniendo en cuenta la longitud eléctrica y el retraso de fase de la señal. Cuando las ondas que viajan por ambos caminos se recombinan en fase a la salida, el modelo reproduce matemáticamente el fenómeno de resonancia.

Este modelo circuital resulta crucial para la caracterización precisa del sustrato FR4. Las capacitancias parásitas del gap introducen una carga reactiva sobre el anillo que provoca un ligero desplazamiento de la frecuencia de resonancia medida ($f$) con respecto a la frecuencia de resonancia ideal calculada teóricamente.

Para que las ecuaciones simplificadas vistas anteriormente (@ec:eff_ring y @ec:tan_delta) sean válidas sin necesidad de  cálculos complejos basados en este modelo, se debe asegurar operativamente un régimen de acoplamiento muy débil. Físicamente, esto implica diseñar gaps lo suficientemente grandes para minimizar la magnitud de $C_2$, pero lo sufucientemente chico como para poder acoplar la señal.

=== Acoplador Direccional


Los acopladores direccionales son dispositivos pasivos de microondas utilizados para dividir o combinar potencia en redes de radiofrecuencia, permitiendo controlar la energía entre distintos puertos. Estos dispositivos forman parte de una familia de componentes que incluyen también divisores de potencia.

Un acoplador direccional se modela como una red de cuatro puertos. Cuando una señal se aplica en uno de los puertos, la mayor parte de la potencia se transmite hacia el puerto de salida principal, mientras que una fracción de la señal es acoplada hacia otro puerto. El cuarto puerto se denomina puerto aislado, ya que idealmente no recibe potencia cuando la señal se propaga en la dirección prevista.

La característica de un acoplador direccional es su capacidad para acoplar potencia de forma dependiente de la dirección de propagación de la onda en la línea de transmisión. De esta manera, el dispositivo puede distinguir entre ondas que se desplazan en direcciones opuestas, lo que resulta particularmente útil para medir potencia directa y reflejada en sistemas de RF.



=== Parámetros característicos

El comportamiento de un acoplador direccional se describe mediante varios parámetros fundamentales:

- *Factor de acoplamiento ($C$):* Indica la relación entre la potencia aplicada al puerto de entrada y la potencia que aparece en el puerto acoplado. Se define como:
  $ C = -10 log_10(P_3 / P_1) #text("[dB]") $

- *Aislamiento ($I$):* Describe la cantidad de potencia que aparece en el puerto aislado cuando se aplica una señal en el puerto de entrada. En un acoplador ideal, el aislamiento sería infinito, aunque en dispositivos reales presenta un valor finito.
  $ I = -10 log_10(P_4 / P_1) #text("[dB]") $

- *Directividad ($D$):* Mide la capacidad del acoplador para separar las ondas que se propagan en direcciones opuestas dentro de la línea de transmisión. Este parámetro se define como la diferencia entre el aislamiento y el acoplamiento. Dado que la directividad no suele medirse de forma explícita o directa, se calcula mediante la relación:
  $ D = I - C #text("[dB]") $
  Una directividad elevada indica que el acoplador puede distinguir de forma efectiva entre la potencia incidente y la potencia reflejada.

- *Pérdida de inserción ($L$):* Corresponde a la reducción de potencia que experimenta la señal al atravesar el acoplador por la línea principal. En un dispositivo ideal esta pérdida sería nula, aunque en la práctica siempre existe una pequeña atenuación debido a las pérdidas en los materiales dieléctricos y en los conductores de la estructura.
  $ L = -10 log_10(P_2 / P_1) #text("[dB]") $


=== Acoplador direccional de líneas acopladas

Una de las implementaciones más comunes y utilizadas en circuitos de microondas es el acoplador direccional de líneas acopladas. Consiste en dos líneas de transmisión dispuestas en paralelo a una distancia pequeña entre sí. Esta configuración permite que los campos electromagnéticos asociados a la propagación de la señal en la línea principal interactúen con la línea adyacente, produciendo una transferencia controlada de potencia, pero manteniendo una separación adecuada para no afectar significativamente la propagación original.

Estos acopladores se implementan frecuentemente en tecnología _microstrip_, donde las líneas de transmisión se fabrican mediante pistas conductoras sobre un sustrato dieléctrico. Debido a su simplicidad de fabricación, son ampliamente utilizados en sistemas de RF para el monitoreo de potencia, la medición de ondas reflejadas y aplicaciones de instrumentación.

#v(-0.5cm)
#subpar.grid(
  figure(image("imgs/ilustrations/acoplador_direccional_microstrip.png"), caption: [Acoplador direccional microstrip]), <fig:acoplador_direccional_microstrip>,
  figure(image("imgs/ilustrations/acoplador_direccional_stripline.png"), caption: [Acoplador direccional stripline]), <fig:acoplador_direccional_stripline>, 
  columns: (1fr, 1fr),
  gap:0.5cm,
  gutter:-0cm,
  caption: [Acopladores direccionales _microstrip_ y _stripline_],
)
Físicamente, un acoplador direccional de este tipo posee cuatro puertos bien definidos:
- *Puerto 1:* Puerto de entrada (_input port_)
- *Puerto 2:* Puerto de salida principal (_through port_)
- *Puerto 3:* Puerto acoplado (_coupled port_)
- *Puerto 4:* Puerto aislado (_isolated port_)

Cuando una señal se aplica al puerto de entrada, la mayor parte de la potencia se transmite hacia el puerto de salida principal, mientras que una pequeña fracción es transferida a la línea acoplada (puerto 3). Idealmente, el puerto aislado no recibe señal debido a la cancelación de fase producida por la direccionalidad del dispositivo. 

El nivel de acoplamiento depende directamente de la geometría de la estructura. Una menor distancia de separación entre las pistas (_gap_) produce un mayor acoplamiento electromagnético, mientras que una separación más amplia reduce la cantidad de potencia transferida.



==== Análisis de modos y longitud del acoplador

El comportamiento de estas estructuras se describe mediante la superposición de dos modos de propagación fundamentales: el modo par (_even mode_) y el modo impar (_odd mode_), tal como se detalla en el libro _Microwave Engineering_ de David M. Pozar.

En el *modo par*, las tensiones en ambas líneas son iguales y están en fase, haciendo que las corrientes fluyan en la misma dirección, como consecuencia, el plano de simetría entre las líneas se comporta como un muro magnético perfecto (PMC), donde el campo magnético tangencial es nulo. Este modo está regido por la impedancia característica par $Z_(0 e)$.

Por el contrario, en el *modo impar*, las tensiones son iguales en magnitud pero desfasadas $180 degree$, por lo que las corrientes circulan en direcciones opuestas, en este caso el plano de simetría actúa como un muro eléctrico perfecto (PEC), donde el campo eléctrico tangencial es nulo. Este modo tiene una impedancia característica denominada impedancia impar $Z_(0 o)$.

#figure(
  image("imgs/placeholder.jpg", width: 30%),
  caption: [Distribución de campos para el modo par e impar en líneas acopladas.]
)<fig:modos_par_impar>

 Debido a que las condiciones de frontera para cada modo son distintas, las señales par e impar experimentan diferentes distribuciones de campo y acumulan fases distintas a lo largo de la región acoplada.

Para que el dispositivo presente el comportamiento deseado, las contribuciones de ambos modos deben interferir de forma destructiva en el puerto aislado y constructiva en el puerto acoplado. Esta condición de interferencia óptima se logra cuando la longitud física de la región donde las líneas permanecen paralelas es exactamente igual a un cuarto de la longitud de onda a la frecuencia central de diseño.

Bajo esta premisa, las señales provenientes de los modos par e impar se combinan de tal forma que se logra la direccionalidad del componente. Por lo tanto, la longitud física ($L$) de la región de acoplamiento se define mediante la ecuación (@ec:longitud_acoplador).

$ L = lambda / 4 $<ec:longitud_acoplador>


=== Relación entre impedancias y acoplamiento

El factor de acoplamiento del dispositivo está determinado por la relación entre las impedancias de los modos par e impar. Para un acoplador ideal simétrico, estas impedancias deben cumplir la relación:

$ Z_(0 e) dot Z_(0 o) = Z_0^2 $

Donde $Z_0$ es la impedancia característica de la linea de transmisión, tipicamente $50 Omega$. Además, el factor de acoplamiento puede expresarse en términos de estas impedancias como:

$ C =20 dot log ((Z_(0 e) + Z_(0 o))/ (Z_(0 e) - Z_(0 o))) $<ec:fact_c>

lo cual permite determinar el diseño geométrico necesario para lograr un determinado valor de acoplamiento.


Teniendo en cuenta que el coeficiente de acoplamiento ($ k$) es la relación de tensión entre el puerto acoplado y el puerto de entrada.

$ k = V_3/V_1  $<ec:coef_c>

Siendo $V_3$ la tensión del puerto 3 y $V_1$ la tensión del puerto de entrada.

La forma de calcular las impedancias del modo par e impar se calculan con  la @ec:impedancia_par y la @ec:impedancia_impar.

  $ Z_(0 e) =  Z_0 dot sqrt((1+k)/(1-k)) $<ec:impedancia_par>

  $ Z_(0 o) =Z_0 dot sqrt((1-k)/(1+k)) $<ec:impedancia_impar>

Donde k es el coeficiente de acoplamiento, no confundir con el factor de acoplamiento.




==== Acoplador híbrido de cuadratura o branch line
$epsilon_r$
El acoplador en cuadratura es un tipo particular de acoplador direccional de cuatro puertos que divide la potencia de entrada en dos salidas de igual amplitud, pero con una diferencia de fase de $90 degree$ entre ellas. Debido a esta característica.


#figure(
image("imgs/ilustrations/acoplador_hibrido_dibujo.png", width: 60%),
  caption: [Acoplador en cuadratura]
)

Cuando una señal se aplica en uno de los puertos de entrada, la potencia se divide equitativamente entre dos de los puertos restantes, mientras que el cuarto puerto permanece idealmente aislado.

Si la señal se aplica al puerto 1, la potencia se divide entre los puertos 2 y 3, cada uno recibiendo la mitad de la potencia de entrada ($3$ [dB] de acoplamiento y $3$ [dB] en el puerto de salida). Además, las señales en estos dos puertos presentan una diferencia de fase de $90 degree$, mientras que el puerto 4 permanece aislado en condiciones ideales.

== Mediciones

=== Parámetros S

En circuitos de microondas, el análisis de redes se realiza comúnmente mediante parámetros de dispersión, también conocidos como parámetros 'S'o parámetros de dispersión. Estos parámetros permiten describir el comportamiento de un dispositivo de múltiples puertos en términos de ondas incidentes y reflejadas en cada uno de sus puertos.

#v(-0.5cm)
#figure(
image("imgs/placeholder.jpg", width:30%),
caption: [imagen en bloques de un acoplador (4 puertos)]
)


Los parámetros de dispersión se definen como la relación entre la onda que sale de un puerto y la onda incidente en otro puerto, manteniendo todos los demás puertos terminados en la impedancia característica del sistema. De esta forma, el parámetro $S_(i j)$​ representa la fracción de la señal aplicada en el puerto $j$ que aparece en el puerto $i$.


Los parámetros S pueden ser representados en una forma matricial para n cantidad de puertos,
cuya cantidad de elementos será $n^2$ puertos.

Para un dispositivo de cuatro puertos, como el acoplador direccional analizado en este trabajo, la red puede describirse mediante una matriz de dispersión de 4×4 , donde cada elemento corresponde a una relación de transmisión o reflexión entre dos puertos.

$ mat(
  S_(1 1), S_(1 2), S_(1 3), S_(1 4);
  S_(2 1), S_(2 2),S_(2 3), S_(2 4);
  S_(3 1), S_(3 2), S_( 3 3), S_(3 4);
  S_(4 1), S_(4 2), S_(4 3), S_(4 4);
) $<ec:matriz_s>

En el caso particular de un acoplador direccional, ciertos parámetros poseen interpretaciones físicas específicas:

- *$S_(1 1)$ *  = Mide la reflexión en el puerto de entrada aplicando la señal de estimulo en el puerto de entrada, esta reflexión esta asociada a la adaptación de impedancia del dispositivo.

- *$S_(2 1)$* = transmisión entre el puerto de entrada y el puerto de salida principal, que representa la potencia que continúa propagándose por la línea principal.

- *$S_(3 1)$* = coeficiente de acoplamiento, aplicando una señal en el puerto 1, se mide la señal en el puerto 3, el cual es una fracción de la señal que se aplico en el puerto de entrada.

- *$S_(4 1)$* = coeficiente asociado al puerto aislado, aplicando de nuevo la señal en el puerto 1.

El uso de parámetros S resulta especialmente conveniente en frecuencias de microondas, ya que permite caracterizar experimentalmente el dispositivo mediante instrumentos como el analizador de redes vectorial (VNA), el cual mide directamente estos parámetros en función de la frecuencia. En la siguiente sección se describirá el principio de funcionamiento de este instrumento y su utilización para la medición del acoplador direccional desarrollado en este trabajo.

=== Analizador de redes vectoriales (VNA)

Un analizador de redes vectoriales es un instrumento que nos permite medir los ya mencionados parámetros S.

La forma en la que el VNA caracteriza los parámetros S del dispositivo es haciendo incidir una
señal de tensión a modo de estimulo en uno de los puertos del DUT (Device Under Test). Si se coloca una carga en el puerto 2 y se mide la relación presente entre la onda reflejada e incidente en el puerto 1, da como resultado el parámetro $S_(1 1)$ . En caso de evaluar la relación entre la onda transmitida del puerto 1 al 2 con la señal estimulo aplicada en el puerto 1 obtenemos el parámetro $S_(2 1)$ . Por otro lado, si invertimos el DUT, es decir la carga es colocada en el puerto 1 y la señal de estimulo es incidida en el puerto 2 podremos medir el parámetro $S_(2 2)$ al relacionar la onda reflejada con incidente en el puerto 2. Por último, si se relaciona la onda transmitida del puerto 2 al 1 (reflejada en el puerto 1) con la señal estimulo aplicada en el puerto 2 obtenemos el parámetro $S_(1 2)$.
Es importante recordar que las relaciones medidas son en dB y grados sexagesimales para la magnitud y fase respectivamente.

=== Calibración del VNA

#subpar.grid(
  show-sub-caption: 10pt
)

#v(-0.5cm)
#subpar.grid(
  figure(image("imgs/calibracion_vna.jpg", width: 90%,height: 4.5cm,fit: "stretch"), caption: [
   Calibración del VNA terminador"Open"
  ]),
  figure(image("imgs/cal_vna.jpg",width: 90%,height: 4.5cm), caption: [
  Calibración VNA terminador _"Short"_
  ]),
  columns: (1fr, 1fr),
  gutter:1cm,
  gap:0.5cm,
  caption: [Calibración del VNA],
  label: <fig:calibración>,
)



Al momento de realizar una medición es importante realizar siempre una calibración con el
objetivo de mitigar los errores sistemáticos de origen instrumental. La calibración básica de un
VNA tiene nombre propio, calibración tipo SOLT.
SOLT es la sigla para “*Short*” ( cortocircuito), “*Open*” (circuito Abierto), “*Load*” (carga) y “*Thru*” (inter-puerto). Habitualmente esta se realiza mediante el software de calibración provisto por el fabricante del instrumento. El objetivo de las primeras tres instancias de calibración es evaluar la exactitud con la que mide el instrumento en casos extremos como lo son un cortocircuito, un circuito abierto o con una carga normalizada de 50 Ω habitualmente.

La instancia *Thru* es fundamental para la correcta medición de los coeficientes de transmisión de modo que será tenido en mayor consideración durante la caracterización de la línea de transmisión, no así las instancias anteriores, fundamentales para obtener resultados exactos al medir los coeficientes de reflexión.

En otras palabras, la calibración desplaza el plano de referencia a los conectores SMA, eliminando cualquier asi los errores sistematicos del instrumento o los propios cables. 

Es mandatorio mencionar que una calibración como la mencionada puede ser considerada seriamente como tal cuando esta se realiza en adición al uso de pinzas torquimétricas para el ajuste de conectores de tal modo que la calibración sea reproducible y se evite dañar los conectores, pudiendo
ocasionar errores no deseados en la medición. Así mismo destacamos que durante el proceso de medición se procedió con la limpieza mediante alcohol isopropílico de conectores y cables con el fin de no aumentar involuntariamente las perdidas de inserción.

#todo("llevar la parte del analizador de espectro como anexo")
=== Analizador de espectro


El analizador de espectro es un instrumento de medición utilizado para analizar señales en el dominio de la frecuencia. A diferencia de instrumentos como el osciloscopio, que muestran la amplitud de una señal en función del tiempo, el analizador de espectro representa la potencia de la señal en función de la frecuencia, permitiendo observar las distintas componentes espectrales que la conforman.

#figure(
  image("imgs/analizador_medición.jpg", width: 30%,height: 5.5cm,fit: "stretch"), 
  caption: [Medición en el analizador de espectro]
)

En la pantalla del instrumento, el eje horizontal corresponde a la frecuencia, mientras que el eje vertical representa la amplitud o potencia de la señal, generalmente expresada en unidades logarítmicas como dBm.



#figure(
  image("imgs/analizador_spectro.png", width: 50%),
  caption: [Diagrama en bloques de un analizador de espectro]
)<fig:analizador_espectro>



De acuerdo con el documento Spectrum Analyzer Basics #todo("Poner referencia"), en este tipo de instrumento, la señal de entrada se mezcla con la señal generada por un oscilador local (LO) cuyo valor de frecuencia se barre a lo largo del rango que se desea analizar. Como resultado del proceso de mezcla se generan componentes de frecuencia suma y diferencia, de las cuales se selecciona una mediante un filtro de frecuencia intermedia (IF).

A medida que el oscilador local barre el rango de frecuencias seleccionado, el analizador mide la potencia de las componentes que pasan por el filtro IF. Esta información se procesa y se representa en la pantalla del instrumento, reconstruyendo de esta forma el espectro de la señal de entrada.

Los analizadores de espectro son ampliamente utilizados en el análisis de sistemas de radiofrecuencia y microondas, ya que permiten medir el nivel de potencia de señales RF, detectar armónicos o señales espurias y evaluar el comportamiento espectral de transmisores y dispositivos electrónicos.

Como se puede observar, el analizador de espectro es un instrumento utilizado principalmente para medir y visualizar el contenido espectral de una señal, es decir, su potencia en función de la frecuencia. A diferencia de un analizador vectorial de redes, no está diseñado para inyectar una señal en un puerto y medir la respuesta en otro puerto del dispositivo bajo prueba.

Sin embargo, algunos analizadores de espectro incorporan una función denominada Tracking Generator (TG), que permite generar una señal cuya frecuencia sigue el barrido del analizador. De esta manera, es posible inyectar una señal en el dispositivo bajo prueba y medir su respuesta en frecuencia utilizando el propio analizador, lo que permite realizar mediciones básicas de transmisión en dispositivos como filtros, amplificadores o líneas de transmisión, en nuestro caso particular utilizaremos dicha función para caracterizar los paraemtros fundamentales de un acoplador direccional (_Coupling_, _Isolation_, _Pérdida de transmisión directa e inversa_). 

= Caracterización del sustrato

Para caracterizar la linea microstrip se emplearán modelos de dispersión y pérdida ampliamente utilizados.
El comportamiento de la permitividad efectiva se modelará mediante el modelo quasi-estatico de Hammerstad y Jensen.

A frecuencias más altas, la evolución de la permitividad sigue la tendencia descrita por Kirschning y Jansen, basada en una corrección empírica dependiente de la geometría.
En cuanto a pérdidas, se considerará que la  pérdida inserción de es predominantemente de origen dieléctrico (proporcional a la frecuencia), mientras que las pérdidas por conducción y radiación se consideran despreciables.

Para la parte experimental se desarrollarán tres métodos para la caracterización sobre el sustrato FR4.



Hammerstad y jensen

$ epsilon_(e f f)(W,h.epsilon_r) = (epsilon_r+1)/2 + (epsilon_r-1)/2 dot (1 + 10 h/W)^(-a(u) b(epsilon_r)) $

$ a(u) = 1+ 1/49 dot ln((u^4 + (u/52)^2)/(u^4 + 0.432)) + 1/18.7 dot ln(1 + (u/18.1)^3) $

$ b(epsilon_r) = 0.564 dot ((epsilon_r - 0.9)/(epsilon_r + 3))^0.053 $

$ u = W/h $

$ Z_(L) (W,h) = Z_(F 0)/ (2 pi sqrt(epsilon_r)) dot ln(f_u h/W + sqrt(1 + ((2 h) /W)^2)) $

$ f_u = 6 + ( 2 pi - 6) dot exp(-(30.666 dot h/W)^0.7528) $




Modelo de  Kirschning y Jansen

#todo("f h debe ser ghz por cm")

$epsilon_(e f f) (f) = epsilon_r - ((epsilon_r - epsilon_(e f f)(f=0))/(1 + p(f)))$

$p(f)= p_1 p_2 [(0.1844 + p_3 p_4) 10 f h]^1.5763$

$p_1 = 0.27488 + [0.6315 + 0.525/(1+ 0.157 f h)^20] u - 0.065683 exp(-8.7513 u)$

$p_2 = 0.33622 [1-exp(- 0.03442 epsilon_r)]$

$p_3 = 0.0363 exp(-4.6 u) dot {1- exp[-((f h)/3.87)^4.97]} $




$p_4 = 1 + 2.751 {1- exp[-(epsilon_r/15.916)^8] } $
== Método 1: stubs de microstrip

El primer método consiste en la utilización de stubs de microstrip con terminación de circuito abierto de diferentes longitudes, fabricados sobre un sustrato FR4, con el objetivo de estimar la permitividad efectiva ($epsilon_(e f f)$) del sustrato FR4.

=== Simulación y diseño

En la etapa de diseño se determinaron las dimensiones geométricas de los stubs empleando modelos analíticos para microstrip como Hammerstad y jensen, considerando una impedancia característica de 50 Ω. Se diseñaron stubs de distintas longitudes eléctricas correspondientes a fracciones de la longitud de onda para una frecuencia de #qty[915][MHz], en particular  $lambda/2,lambda/4, lambda/8 $.

Adicionalmente, se implementaron stubs de longitudes físicas de #qty[50][mm] y #qty[100][mm], con el objetivo de generar resonancias en distintas frecuencias.



#todo("AGREGAR FOTOS DE USO DE QUCS Y FEKO y mencionar uso del simulador")

=== Implementación
En esta etapa de implementación se realizó el PCB con los stubs después de simularlos para luego medir y caracterizar el sustrato.

#subpar.grid(
  figure(image("imgs/ring_y_stubs_cinta.jpg",height: 5cm,width: 100%)),
  // figure(image("imgs/anillos_stubs_filmina_fr4.png",height: 3.5cm)),
  figure(image("imgs/anillos_stubs_fr4_listos.png",height: 5cm,width: 100%)),
  columns: (1fr,1fr),
  caption: [Fabricación de los PCBs],
  gap: 0.5cm, 
  label: <fig:pcb>,
)



=== Mediciones

Una vez fabricados los stubs, las mediciones se llevan a cabo mediante un analizador vectorial de redes (VNA). En particular, se mide el parámetro $ S_(1 1)$, correspondiente al coeficiente de reflexión en el puerto de entrada.

Se realizaron las mediciones desde #qty[100][MHz] hasta #qty[6][GHz] con 1001 puntos por lo que la medición se realizó a pasos 
de #qty[5.89][MHz].

#figure(
image("imgs/stub_un_cuarto.jpg", width: 45%),
caption: [medición del stub de un cuarto de longitud de onda]
)<fig:stub_un_cuarto>

A partir de las mediciones de fase obtenidas para cada stub, se analizan los datos utilizando un _script_ en _python_, en un incio busca los cruces por cero detectando la pendiente positiva, ya que esos puntos se consideran puntos de resonancia. 

Sin embargo, dado que el VNA entrega la fase envuelta (_wrapped_), es decir, la fase tiene saltos abruptos en las frecuencias de resonancia que va desde #qty[-180][$degree$] a #qty[180][$degree$], por lo que la hace susceptible al ruido de fase o espurios que pueda tener la señal.


Por consiguiente se utilizó un algoritmo para densenvolver la fase (_unwrapped_), el cual hace que la fase sea lineal eliminando esas discontinuidades. Este proceso elimina el ruido o espurios que tenga la señal por lo que es mas exacto al momento de obtener esas frecuencias de resonancia, pues se obtienen en multiplos de #qty[180][$degree$].

Dado que la discretización de la señal es cada #qty[5.89][MHz], puede que se omita el valor exacto de la frecuencia de resonancia, por lo que se decidió  mejorar el proceso de detección de las resonancias. Para la primera resonancia, a la fase desenvuelta (_unwrapped_) se le calculó el módulo y a la señal resultante se le resto #qty[180][$degree$], con este proceso
la frecuencia de resonancia se encuentra en el cruce por cero, por ende se utilizó el algoritmo para dectar el cruce por cero.
Este proceso se itero restando multiplos de #qty[180][$degree$] para localizar todas las resonancias como cruce por cero de la señal. 


Como se ilustra en la #todo("IMAGEN") las frecuencias de resonancia son aproximadamente multiplos impares debido a que se trata de stubs con terminación a circuito abierto. 

Al obtener todas las frecuencias de resonancia de cada stub, se analizan de a pares y se otiene el epsilon efectivo promedio 
utilizando la @ec:eff_stubs, teniendo en cuenta que se deben utilizar los armónicos de igual valor, es decir, el primer armónico de un stub con el primer armónico del otro stub.

#todo("Agregar todo lo que cambio como el uso de cuadrados minimos (LLS) y el uso continuo de datos")

Es importante notar que como se ilustra en la #todo("IMAGEN con el notch en 4GHz y pico") para frecuencias superiores a #qty[4.5][GHz] la medición se ve afectada por las resonancias de los conectores, por ende este rango de frecuencias fue excluido del cálculo final para medir el $epsilon_(e f f)$ del sustrato. 

#todo("agregar foto de los stubs filtrados con linea punteada los excluidos")

== Método 2: Resonadores de anillo 

El segundo método se basa en resonadores de anillo implementados sobre el sustrato FR4. Estos dispositivos presentan resonancias a frecuencias específicas que dependen de la permitividad efectiva del material y de las dimensiones geométricas del resonador.
=== Simulación y diseño

#todo("AGREGAR COSAS")

=== Implementación




#todo("AGREGAR COSAS")
=== Mediciones


Las mediciones se realizan utilizando el analizador vectorial de redes (VNA), registrando el parámetro $S_(2 1)$, correspondiente al coeficiente de transmisión, a lo largo de un rango de frecuencias.

El análisis de la respuesta en frecuencia permite identificar las frecuencias de resonancia del anillo. A partir de estas frecuencias, y utilizando la relación presentada en @ec:eff_ring, es posible estimar la permitividad efectiva del sustrato.

Asimismo, el comportamiento del coeficiente de transmisión alrededor de la resonancia permite estimar las pérdidas dieléctricas del sustrato mediante algoritmos basados en los modelos teóricos mencionados previamente.


== Método 3: Medición de capacitancia

El tercer método consiste en un capacitor plano implementado sobre el mismo sustrato FR4. La capacitancia de este dispositivo depende directamente de la permitividad efectiva del dieléctrico y de la geometría del capacitor.

=== Diseño

En este caso se realizó el capacitor con una placa FR4 de #qty[35][mm]x#qty[50][mm] 


=== Mediciones


Finalmente, el tercer método consiste en la medición de la capacitancia de un capacitor plano fabricado sobre el mismo sustrato FR4. A partir del valor medido de capacitancia y utilizando la relación mostrada en la @ec:capacitancia, se calcula la permitividad efectiva del material:

$ C = (epsilon_(e f f) dot A)/d $<ec:capacitancia>

Siendo d la distancia entre placas  y A el área del capacitor.


= Ánalisis de resultados

= Diseño de un acoplador direccional  

El objetivo del trabajo es diseñar, simular y caracterizar un acoplador direccional en tecnología microstrip centrado en 915 MHz, capaz de manejar una potencia de 5 W. Este componente formará parte del proyecto general y será destinado a la medición de potencia reflejada y el monitoreo del ajuste de antena, permitiendo obtener el coeficiente de reflexión a partir de la señal acoplada, aunque para este trabajo se acota el trabajo hasta la realización de acoplador direccional.

El desarrollo se realizará utilizando uSimmics (Qucs-studio) como herramienta principal de simulación, siendo un software libre y sin costo permitiendo analizar y simular las líneas acopladas y una implementación alcanzable en el marco del proyecto, aunque los resultados podrían contrastarse posteriormente con herramientas como Feko

El diseño teórico se basará en el modelo de modos par e impar (even/odd), a partir del cual se determinarán los parámetros de acoplamiento ($C$) y directividad ($D$). Estos parámetros serán validados mediante simulaciones electromagnéticas.

Se realizará un barrido paramétrico sobre el espaciado entre líneas, ancho de pista y longitud de acoplamiento, con el fin de optimizar la respuesta en frecuencia del acoplador y lograr un acoplamiento que si bien todavia no fue definido con rigurosidad será próximo a –30 dB en la frecuencia central.

Finalmente, el acoplador se fabricará sobre el mismo sustrato caracterizado (FR4), se medirán sus parámetros $S_(11)$, $S_(21)$, $S_(31)$ y $S_(41)$ mediante un analizador vectorial de redes (VNA), y se evaluará la directividad obtenida comparando la potencia acoplada hacia los puertos acoplado y aislado. 
  
      // En un acoplador direccional ideal, las pérdidas por inserción y las pérdidas por acoplamiento son idénticas. En la práctica, las pérdidas por inserción serán una combinación de pérdidas de acoplamiento, pérdidas dieléctricas, pérdidas del conductor y pérdidas por ROE. Dependiendo del rango de frecuencias, las pérdidas por acoplamiento son menos significantes con un acoplamiento superior a 15

== Implementación del acoplador direccional


Al momento de la implementación física del dispositivo en un PCB se decició hacerlo mediante un proceso fotolitografico. Dicho método fue escogido con el fin de minimizar las variaciones físicas en las dimesiones de las estructuras debido a que la exactitud de los métodos de estimación utilizados es altamente sensible a la geometría.  


// Luego de simulaciones y diseño de acopladores direccionales se realiza la implementación de un acoplador, utilizando el método
//  de fotolitografía con el objetivo de maximizar la resolución geométrica del mismo, debido a que los parámetros fisicos como la separación entre lineas (_gap_), el ancho y la longitud de la linea en la región de acoplamiento, son muy criticos ya que 
// afectan de manera directa a las impedancias par (_even_) e impar (_odd_) y esto a su vez afecta al factor de acoplamiento, por ende también afeta la directividad del dispositivo.

Por otro lado también se realizaron acopladores de prototipo hechos manualmente con cinta de cobre sobre el FR4, donde se fue 
iterando hasta conseguir una directividad alrededor de los #qty[20][dB]. Este proceso se hizo tanto para acoplador microstrip como stripline para
poder observar de manera experimetal la diferencia entre ellos.


#subpar.grid(
  figure(image("imgs/coupled_insoladora.jpg",fit: "stretch",height: 4cm,width: 70%)),
  figure(image("imgs/acopladores_diseñados.jpg",fit: "stretch",height: 4cm,width:70%)),
  columns: (1fr,1fr),
  caption: [Fabricación de los acopladores direccionales],
  gutter: -2cm,
  gap: 0.5cm, 
  label: <fig:pcb_acoplador_direccional>,
)


== Mediciones del acoplador Direccional

Al momento de medir el acoplador, utilizando el analizador vectorial de redes (VNA), se registró los parámetros $S_11$ (coeficiente de reflexión), $S_21$ (coeficiente de transmisión), $S_31$ (coeficiente de acoplamiento) y $S_41$ (coeficiente de aislación) el cual son los parametros caracteristicos de un acoplador y a su vez se calcula la directividad del mismo.

Es importante que como el VNA tiene solo dos puertos, al momento de medir los puertos que no estan conectados al instrumento tengan una carga de #qty[50][$Omega$].


#pagebreak()

#figures_matrix(
  description: "Medición del puerto de salida",
  port_name:"output",
  dir_coupler_name: "ACD1",
  mag:"imgs/ACD1/adc1_through_mag_s11_s21.png",
  pha:"imgs/ACD1/adc1_through_phase_s11_s21.png",
  smith:"imgs/ACD1/adc1_through_smith_s11.png",
  dut:"imgs/ACD1/adc1_through_bench.jpg",
  offset_dut_pt:30pt
)


#figures_matrix(
  description: "Medición del puerto acoplado",
  port_name:"acoplado",
  dir_coupler_name: "ACD1",
  mag:"imgs/ACD1/adc1_coupled_mag_s11_s21.png",
  pha:"imgs/ACD1/adc1_coupled_phase_s11_s21.png",
  smith:"imgs/ACD1/adc1_coupled_smith_s11.png",
  dut:"imgs/ACD1/adc1_coupled_bench.png",
  offset_dut_pt:0pt
)


#figures_matrix(
  description: "Medición del puerto aislado",
  port_name:"aislado",
  dir_coupler_name: "ACD1",
  mag:"imgs/ACD1/adc1_isolated_mag_s11_s21.png",
  pha:"imgs/ACD1/adc1_isolated_phase_s11_s21.png",
  smith:"imgs/ACD1/adc1_isolated_smith_s11.png",
  dut:"imgs/ACD1/adc1_isolated_bench.jpg",
  offset_dut_pt:26pt
)


#pagebreak()
#todo("Modificar la foto del nuevo aislado" )

Midiendo el acoplador de manera inversa, es decir, el puerto 1 ahora es el puerto 2:

#figures_matrix(
  description: "Medición del puerto acoplado y del puerto aislado con el DUT invertido",
  port_name:"acoplado",
  dir_coupler_name: "ACD1_inverted",
  mag:"imgs/ACD1/adc1_isolatedInverted(new-coupled)_mag_s11_s21.png",
  smith:"imgs/ACD1/adc1_isolated_inverted_bench.jpg",
  pha:"imgs/ACD1/adc1_coupledInverted(new-Isolated)_mag_s11_s21.png",
  dut:"imgs/ACD1/adc1_coupled_inverted_bench.jpg",
  cap_smith_opt: "Setup para medición del puerto acoplado del DUT",
  cap_dut_opt: "Setup para medición del puerto aislado del DUT",
  cap_pha_opt: "Magnitud (dB) del parámetro de reflexión y transmisión del puerto aislado",
  cap_mag_opt: "Magnitud (dB) del parámetro de reflexión y transmisión del puerto acoplado",
  offset_dut_pt: -10pt, 
  offset_smith_pt: -14pt
)

#pagebreak()





El segundo acoplador direccional microstrip el cual fue simulado y diseñado con cinta de cobre para prototipar obtenemos las siguientes mediciones. 


#figures_matrix(
  description: "Medición del puerto de salida",
  port_name:"output",
  dir_coupler_name: "ACD2",
  mag:"imgs/ACD2/adc2_through_mag_s11_s21.png",
  pha:"imgs/ACD2/adc2_through_phase_s11_s21.png",
  smith:"imgs/ACD2/adc2_through_smith_s11.png",
  dut:"imgs/ACD2/adc2_through_bench.jpg",
  offset_dut_pt:42pt
)


  // mag:"https://www.researchgate.net/profile/Erick-Reyes-Vera/publication/308926650/figure/fig1/AS:414578841276416@1475854706479/Figura-2-Anillos-resonadores-elemento-propuesto-por-J-Pendry-La-disposicion-de-las_Q320.jpg",

#figures_matrix(
  description: "Medición del puerto acoplado",
  port_name:"acoplado",
  dir_coupler_name: "ACD2",
  mag:"imgs/ACD2/adc2_coupled_mag_s11_s21.png",
  pha:"imgs/ACD2/adc2_coupled_phase_s11_s21.png",
  smith:"imgs/ACD2/adc2_coupled_smith_s11.png",
  dut:"imgs/ACD2/adc2_coupled_bench.jpg",
  offset_dut_pt:26pt
)

 #figures_matrix(
   description: "Medición del puerto aislado",
   port_name:"aislado",
   dir_coupler_name: "ACD2",
   mag:"imgs/ACD2/adc2_isolated_mag_s11_s21.png",
   pha:"imgs/ACD2/adc2_isolated_phase_s11_s21.png",
   smith:"imgs/ACD2/adc2_isolated_smith_s11.png",
   dut:"imgs/ACD2/adc2_isolated_bench.jpg",
   offset_dut_pt:43pt
 )


#pagebreak()

El tercer acoplador direccional microsse realizo stripline el cual fue simulado y diseñado con cinta de cobre para prototipar obtenemos las siguientes mediciones.


#figures_matrix(
  description: "Medición del puerto de salida",
  port_name:"output",
  dir_coupler_name: "ACD3",
  mag:"imgs/ACD3/adc3_through_mag_s11_s21.png",
  pha:"imgs/ACD3/adc3_through_phase_s11_s21.png",
  smith:"imgs/ACD3/adc3_through_smith_s11.png",
  dut:"imgs/ACD3/adc3_through_bench.jpg",
  offset_dut_pt:2pt
)


#figures_matrix(
  description: "Medición del puerto acoplado",
  port_name:"acoplado",
  dir_coupler_name: "ACD3",
  mag:"imgs/ACD3/adc3_coupled_mag_s11_s21.png",
  pha:"imgs/ACD3/adc3_coupled_phase_s11_s21.png", 
  smith:"imgs/ACD3/adc3_coupled_smith_s11.png",  
  dut:"imgs/ACD3/adc3_coupled_bench.jpg",
  offset_dut_pt:0pt
)




 #figures_matrix(
   description: "Medición del puerto aislado",
   port_name:"aislado",
   dir_coupler_name: "ACD3",
   mag:"imgs/ACD3/adc3_isolated_mag_s11_s21.png",
   pha:"imgs/ACD3/adc3_isolated_phase_s11_s21.png",
   smith:"imgs/ACD3/adc3_isolated_smith_s11.png",
   dut:"imgs/ACD3/adc3_isolated_bench.jpg", 
   offset_dut_pt:0pt
 )


#pagebreak()
Ahora el cuarto acoplador direccional en stripline


 
#figures_matrix(
  description: "Medición del puerto de salida",
  port_name:"output",
  dir_coupler_name: "ACD4",
  mag:"imgs/ACD_tunning/acd4_through_s11_s21_mag.png",
  pha:"imgs/ACD_tunning/acd4_through_s11_s21_phase.png",
  smith:"imgs/ACD_tunning/acd4_through_s11_smith.png",
  dut:"imgs/ACD_tunning/adc4_through_bench.jpg",
  offset_dut_pt:2pt
)


#figures_matrix(
  description: "Medición del puerto acoplado",
  port_name:"acoplado",
  dir_coupler_name: "ACD4",
  mag:"imgs/ACD_tunning/acd4_coupled_s11_s21_mag.png",
  pha:"imgs/ACD_tunning/acd4_coupled_s11_s21_phase.png",
  smith:"imgs/ACD_tunning/acd4_coupled_s11_smith.png",
  dut:"imgs/ACD_tunning/adc4_coupled_bench.jpg",
  offset_dut_pt:2pt
)

#figures_matrix(
  description: "Medición del puerto aislado",
  port_name:"aislado",
  dir_coupler_name: "ACD4",
  mag:"imgs/ACD_tunning/acd4_isolated_s11_s21_mag.png",
  pha:"imgs/ACD_tunning/acd4_isolated_s11_s21_phase.png",
  smith:"imgs/ACD_tunning/acd4_isolated_s11_smith.png",
  dut:"imgs/ACD_tunning/adc4_through_bench.jpg",
  offset_dut_pt:2pt
)



#pagebreak()

== Analisis de resultados 

En la @tab:mediciones_acoplador_915  se sintetizan los parámetros caracteristicos de los acopladores implementados, evaluados en la frecuencia de diseño  $f =$ #qty[915][MHz]. 

#align(center,
  box(width: 80%,[
    #figure(
      table(
        columns: (0.8fr, 0.8fr, 0.6fr,0.6fr),
        inset: 6pt,
        align: horizon,
        toprule(), // added by this package
        table.header(
          [*Acoplador*], [*Acoplamiento*], [*Aislación*],[*Directividad*],
        ),
          midrule(), // added by this package

          "ACD1",
          qty[-45.58][dB],
          qty[-35.85][dB],
          qty[-9.73][dB],

          "ACD1 invertido",
          qty[-22.01][dB],
          qty[-40.34][dB],
          qty[18.33][dB],

          "ACD2",
          qty[-25.40][dB],
          qty[-41.87][dB],
          qty[16.47][dB],

          "ACD3",
          qty[-43.13][dB],
          qty[-44.10][dB],
          qty[0.97][dB],

          "ACD4",
          qty[-22.02][dB],
          qty[-42.97][dB],
          qty[20.95][dB],
          bottomrule() // added by this package


      ),caption: "Mediciones del acoplador evaludas en 915 MHz"
    )<tab:mediciones_acoplador_915>]
  )
)
En el primer diseño, el ACD1, se obtuvo una directividad negativa de #qty[-9.73][dB], este comportamiento indica que la potencia que se transfirió al puerto aislado es mayor a la del puerto acoplado, por lo que se decide invertirlo.

Al invertir el dispositivo bajo prueba (_DUT_) y repetir la medición, la directividad subió a #qty[18.33][dB]. Este resultado confirma que la respuesta del dispositivo es altamente sensible a la orientación y disposición fisica del acoplador. Al comparar @fig:smith_acoplado_ACD1_inverted y @fig:bench_setup_acoplado_ACD1_inverted se demuestra que la orientación vertical optimiza la directividad del dispositivo. 


El segundo dispositivo otro acoplador microstrip, como indica la @tab:mediciones_acoplador_915, tiene una directividad de #qty[16.47][dB] y un acoplamiento de #qty[-25.40][dB]. Las dimensiones geometrícas de este dispositivo se obtuvieron mediante un barrido paramétrico  en la simulación, ajustando del ancho de la línea (_width_), separación (_gap_) y la longitud paralela a la linea prinicpal, buscando maximizar la directividad del dispositivo. 


El tercer diseño tiene el objetivo de validar el modelo de simulacion  para lineas "stripline" #footnote[Hablamos de stripline con comillas pues la forma de construccion es casera y no tendra la misma precision y exactidud que una fabricada a nivel industrial] del simulador QUCS. Se realizó este prototipo de acoplador direccional en una implementacion "stripline" para luego iterar nuevamente con lo aprendido de este primer prototipo. 

Una de las primeras lecciones aprendidas fue la necesidad de contar con un blindado consistente en el contorno del sustrato mostrando la importancia de confinar correctamente el campo dentro del "_stack-up_". Asi mismo el calor generado por la soldadura al momento de cerrar la caja debe ser rapidamente disipado mientras se la cierra pues el aumento de calor y posibles movimientos involuntarios de las capas del "sandwich" hace que se despegue la cinta de cobre y se mueva arruinando así los ajustes previamente realizados.

El cuarto y último dispositivo es un acoplador direccional stripline, el cual se obtuvo la mayor directividad #qty[20.95][dB]. Este dispositivo se implemento y luego con un cutter se fue modificando de forma sustractiva el gap, el ancho y la longitud (paralela a la linea de transmisión) junto con la simulación. Dichas modificaciones se hicieron de a pasos cortos debido a q si se hacen pasos mas grandes puede modificarse por demás.


#pagebreak()
= Interfaz gráfica para la obtención
Inspirado en las calculadoras de QUCS se decidió implementar una para la obtención del parámetro $epsilon_r$ y $tg(delta)$, adjuntado los archivos del VNA calcule los mismos automatizando el proceso, ademas la misma contará con interfaz de linea de comandos facilitando la posibilidad de hacer scripting. 

// #image("gui.png")

Como comentario adicional, el proyecto se pretende implementar en un pcb FR4 de 4 capas habilitando la posibilidad de realización de _striplines_, minimizando las pérdidas por radiación en la interfaz sutrato/aire *(consultar)*



#image("imgs/ad8302_reflectometer.png") 

#image("imgs/AD8302.png",width: 50%)



// #bibliography("cites.bib") 
