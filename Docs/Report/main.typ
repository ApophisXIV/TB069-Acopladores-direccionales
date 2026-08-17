#import "template.typ": *


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
  it,
)

#set math.equation(numbering: "(1)")
#import "@preview/subpar:0.2.2"
#import "@preview/fancy-units:0.1.0": *


#import "@preview/fancy-units:0.1.1": qty
#import "@preview/simple-plot:0.3.0": plot
#import "@preview/booktabs:0.0.4": *
#show: booktabs-default-table-style
// #import "@preview/cetz:0.2.2":*

#set page(margin: (y: 2.3cm, x: 1in))
#show link: underline

#show <add_to_outline_without_numbering>: set heading(outlined: true, numbering: none)


#let todo(task) = { return text(size: 10pt, fill: red, upper[#task]) }
#let todo_bib(task) = {
  return text(size: 10pt, weight: "black", font: "Trebuchet MS", fill: rgb("#208620"), upper[#task])
}
#let todo_compromiso(task) = {
  return text(size: 10pt, weight: "black", font: "Trebuchet MS", fill: rgb("#a3129c"), upper[#task])
}


#show figure: set text(size: 9pt)


// #heading(outlined: false)[

// -----------------------------------------------------------
// AUX
// -----------------------------------------------------------
#let fn_open_stub(x) = return { -1.0 / calc.tan(x) }
#let fn_short_stub(x) = return { calc.tan(x) }

#let plot_z_stub_vs_l(is_open_stub: true, color_1, color_2, phase_offset) = [
  #let fn_stub = if is_open_stub == true {
    fn_open_stub
  } else {
    fn_short_stub
  }
  #plot(
    xmin: 0.0 * calc.pi,
    xmax: 2.0 * calc.pi - 0.1,
    ymin: -5.5,
    ymax: 6,
    width: 4.5,
    height: 5,
    xlabel: $beta l$,
    ylabel: $Z(l)$,
    show-grid: "none",
    grid-label-break: false, // Defaul
    x-extend: (22, 2),
    axis-y-extend: (1, 1.5),
    show-origin: false, // Avoid duplicate "0" with custom xtick-labels
    ytick: none,

    xtick: (
      // -2.0 * calc.pi,
      // -3.0 / 2.0 * calc.pi,
      // -calc.pi,
      // -calc.pi / 2,
      calc.pi / 2,
      calc.pi,
      3 / 2 * calc.pi,
      2.0 * calc.pi,
    ),
    // xtick-labels: ($-2 pi$, $(- 3 pi)/2$, $- pi$, $- pi/2$, $pi/2$, $pi$, $(3 pi)/2$, $2 pi$),
    xtick-labels: ($pi/2$, $pi$, $(3 pi)/2$, $2 pi$),

    (fn: x => fn_stub(x), stroke: color_1.lighten(50%) + 1.2pt, samples: 175),
    (
      fn: x => fn_stub(x),
      domain: ((-calc.pi + phase_offset - 0.01), (-calc.pi + phase_offset + 0.0)),
      stroke: color_2 + 1.05pt,
      samples: 1,
    ),
    (
      fn: x => fn_stub(x),
      domain: ((-0.00000001 + phase_offset), (0.01 + phase_offset)),
      stroke: color_2 + 1.05pt,
      samples: 1,
    ),
    (
      fn: x => fn_stub(x),
      domain: ((calc.pi + phase_offset - 0.09), (calc.pi + phase_offset + 0.0000001)),
      stroke: color_2 + 1.05pt,
      samples: 1,
    ),
  )
]


// Matriz de figuras

#let figures_matrix(
  description: "",
  port_name: "",
  dir_coupler_name: "",
  mag: "",
  pha: "",
  smith: "",
  dut: "",
  offset_dut_pt: 0pt,
  offset_smith_pt: 0pt,
  cap_mag_opt: "",
  cap_pha_opt: "",
  cap_smith_opt: "",
  cap_dut_opt: "",
) = {
  let mag_caption = if cap_mag_opt.len() == 0 {
    [Magnitud (dB) del parámetro de reflexión ($S_(11)$) y transmisión ($S_(21)$) del puerto "#port_name"]
  } else {
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
  } else {
    auto
  }

  show figure: set text(size: 7pt)
  align(center + horizon)[
    #scale(reflow: false, x: 117%, y: 135%)[
      #rotate(-90deg)[
        #subpar.grid(
          [

            #figure(image(mag), caption: mag_caption)
            #eval("<fig:mag_" + port_name + "_" + dir_coupler_name + ">", mode: "code")
          ],
          [
            #figure(
              box(clip: true, radius: 5pt, outset: -0pt, image(
                fit: "stretch",
                width: 128pt + offset_smith_pt,
                height: h_smith_alt,
                smith,
              )),
              // #figure(image(width: 125pt,height: 160pt,fit: "stretch",smith),
              caption: smith_caption,
            )
            #eval("<fig:smith_" + port_name + "_" + dir_coupler_name + ">", mode: "code")
          ],

          [
            #figure(image(pha), caption: pha_caption)
            #eval("<fig:pha_" + port_name + "_" + dir_coupler_name + ">", mode: "code")
          ],
          [
            #figure(
              box(clip: true, radius: 5pt, outset: -0pt, image(fit: "stretch", width: 128pt + offset_dut_pt, dut)),
              caption: dut_caption,
            )
            #eval("<fig:bench_setup_" + port_name + "_" + dir_coupler_name + ">", mode: "code")
          ],

          columns: (2fr, 1fr),
          caption: [#description],
          gap: 0.5cm,
          gutter: 0.45cm,
        )
      ]
    ]
  ]
}

// -----------------------------------------------------------

// IEEE145 -> Rotulacion standard
// Collins - La biblia real
// La serie roja (mirar los tomos del MIT)







= Introducción general

== Contexto y motivación
En el marco de la asignatura _TB069 - Electromagnetismo Aplicado_ del plan 2023 de la carrera de Ingeniería Electrónica, se presenta la posibilidad de promoción mediante la realización de un trabajo práctico de aplicación por lo que a lo largo de esta memoria se presentará el proceso de diseño, implementación y medición de un acoplador direccional tanto en tecnología _microstrip_ como _stripline_ para el cual de forma preliminar se caracterizará el sustrato sobre el cual será construido mediante tres métodos de medición indirecta los cuales se van a ver detalladamente mas adelante.

== Objetivos y alcances

En el marco de la asignatura _TB069 - Electromagnetismo Aplicado_ del plan 2023 de la carrera de Ingeniería Electrónica, se presenta la posibilidad de promoción mediante la realización de un trabajo práctico de aplicación por lo que a lo largo de este informe se procederá a diseñar e implementar un acoplador direccional para el cual previamente se realizará la caracterización del sustrato mediante tres métodos de medición indirecta: $Delta S$ (diferencia de fase), resonadores de anillo _microstrip_ y medición de capacitancia para diferentes áreas.

Como parte de la actividad del club de radio frecuencia de la facultad, siendo ambos miembros activos del mismo, se presenta la idea de desarrollar un adaptador automático de antena con el fin de estudiar su proceso de diseño y posterior implementación, para ello se determinó la necesidad de diseñar e implementar un *acoplador direccional* del cual se obtendrá el parámetro de reflexión mediante el circuito integrado AD8302, el circuito de control basado en el uso de un microcontrolador y finalmente el circuito de adaptación. De forma paralela se decide *caracterizar el sustrato* con el fin de determinar de forma fehaciente su permitividad relativa ($epsilon_r$) y su $tg(delta)$ logrando así minimizar la discrepancia entre los resultados teóricos y experimentales.

A continuación se presenta un diagrama de bloques de la relación de las diferentes etapas y actividades del proyecto.

#figure(
  image("imgs/esquema_de_trabajo.png", width: 80%),
)


Luego de una primer conversación con el Dr. Ing Gustavo Fano, se decidió tomar una parte acotada del proyecto para ser presentado como propuesta de realización con los siguientes bloques:
- Diseño, simulación e implementación del acoplador direccional incluyendo un marco teórico introductorio y consideraciones prácticas tenidas en cuenta
- Caracterización del sustrato mediante la medición
- Diseño e implementación de una interfaz gráfica que permita analizar los datos experimentales obtenidos necesarios para caracterizar el sustrato

= Introducción específica
A continuación se explicarán algunos conceptos necesarios para llevar a cabo la elaboración del acoplador direccional como así también los métodos de medición empleados.

== Líneas de transmisión
Una línea de transmisión puede ser entendida desde su interpretación como un medio físico que permite transportar energía eléctrica o energía electromagnética y/o información constituido mediante dos o más conductores metálicos, ópticos o de cualquier otro material que permita la propagación eficiente de la energía como así también desde su modelo de análisis siendo propicio de utilizar cuando las dimensiones físicas del sistema son comparables con la longitud de onda de la señal, de modo que los efectos de propagación no pueden ser despreciados.

=== Modelo de la línea de transmisión de parámetros distribuidos
Tal como fue mencionado, para el análisis se cuenta con un denominado modelo equivalente de parámetros distribuidos, en el cual se representan los distintos fenómenos físicos asociados a la propagación de la señal donde se presenta la *resistencia (R)* para modelar las pérdidas en los conductores, la *inductancia (L)* para representar la energía magnética, la  *capacitancia (C)* para representar la energía eléctrica, y la *conductancia (G)* para modelar las pérdidas relacionadas al dieléctrico.

Es importante mencionar que estos parámetros están definidos por unidad de longitud y en la práctica dependen tanto de la geometría de la línea como de las propiedades eléctricas de los materiales que la componen. El conjunto de los cuatro parámetros recibe el nombre de modelo RLGC, y constituye la base para la formulación de las ecuaciones de la línea de transmisión derivadas por Heaviside en la decada de 1880.

#figure(
  image("imgs/ilustrations/rlgc.svg", width: 65%),
  caption: [Modelo RLGC de una linea de transmisión],
)

Aplicando las leyes de Kirchhoff a un segmento infinitesimal $Delta l$,  se obtienen la @ec_tension y @ec_corriente, las denominadas ecuaciones del telegrafista, Pozar #cite(<Pozar>, supplement: [p. 49]), que describen la variación espacial de la tensión y la corriente:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ (d V(l))/(d l) = - (R + J omega L) dot Delta_l dot I(l) $<ec_tension>],
  [$ (d I(l))/(d l) = -(G + j omega C) dot Delta_l dot V(l)) $<ec_corriente>],
  // Segunda ecuación
)

Estas ecuaciones diferenciales de primer orden son la base  para obtener una ecuación diferencial de segundo orden para la tensión y otra para la corriente, conocida como ecuación de Helmholtz (@ec:Helmholtz_tension y @ec:Helmholtz_corriente), que describe la propagación de ondas a lo largo de la línea:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ (d² V(l))/(d² l) - gamma^2 dot V (l) = 0 $<ec:Helmholtz_tension>],
  [$ (d² I(l))/(d² l) - gamma^2 dot I (l) = 0 $<ec:Helmholtz_corriente>],
)

Siendo $gamma$ la constante de propagación de la linea, la misma puede ser expresada en la forma de la @gamma_parametros_concentrados o la @ec:cons_prop, donde $alpha$ es la constante de atenuación que representa la pérdida de amplitud de la señal a lo largo de la línea y $beta$ la constante de fase que describe la variación de fase de la onda durante su propagación.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ gamma = sqrt((j omega dot L + R) dot (j omega dot C + G)) $<gamma_parametros_concentrados>],
  [$ gamma = alpha + j beta $<ec:cons_prop>],
)

Por consiguiente la solución general de la ecuación de Helmholtz conduce a las expresiones de la tensión (@ec:Tension_TL) y corriente (@ec:Corriente_TL) a lo largo de la línea de transmisión:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ V(l) = V^+ dot exp(- gamma dot l) + V^- dot exp(gamma dot l) $ <ec:Tension_TL>],
  [$ I(l) = I^+ dot exp(- gamma dot l) + I^- dot exp(gamma dot l) $ <ec:Corriente_TL>],
)

Donde $V^+$ e $I^+$ representan las ondas incidentes que se propagan en el sentido positivo de la línea, mientras que $V^-$ e $I^-$ representan las ondas reflejadas que se propagan en sentido contrario.

=== Propagación de la señal en una linea de transmisión
La onda electromagnética en una linea de transmisión, se propaga principalmente en el material dieléctrico que separa ambas placas conductoras, es decir lo hace en un medio material.

La onda electromagnética que se propaga a lo largo de una línea de transmisión puede hacerlo mediante distintos modos de propagación, los cuales describen la orientación de los campos eléctrico y magnético con respecto a la dirección de propagación de la onda. Dependiendo de esta orientación, los campos pueden presentar componentes transversales, longitudinales o una combinación de ambas.

#v(-0.5cm)
#figure(
  image("imgs/modoTEMvectores.PNG", width: 5cm),
  caption: [Modo de propagación TEM],
)<fig:modo_tem>

Cuando el campo eléctrico y magnético son completamente transversales a la dirección de propagación, se presenta el modo TEM (Transversal Electromagnético) como se ilustra en la @fig:modo_tem, este modo es más propenso a darse en frecuencias menores al GHz (sub-GHz) y en estructuras principalmente no dispersivas (homogéneas) como pueden ser las _striplines_ o coaxiales, como lo señala Pozar #cite(<Pozar>, supplement: [p.141]), en otras palabras, en estructuras donde haya baja o nula dispersión de la onda electromagnética por fuera del propio confinamiento de la línea.
#todo_bib("Agregar biblio del pozar o algun otro libro sobre TEM en stripline")

También existe el modo TE (Transversal Eléctrico), en el cual el campo eléctrico es completamente transversal a la dirección de propagación, mientras que el campo magnético presenta una componente longitudinal, caso contrario el modo TM (Transversal Magnético) el campo magnético es transversal a la propagación, y el campo eléctrico es quien presenta una componente longitudinal, ambos se ilustran en la @fig:TE y en la @fig:TM respectivamente.

#v(-0.25cm)
#subpar.grid(
  figure(image("imgs/modoTEvectores.PNG", width: 4.5cm), caption: [
    Modo de propagación TE
  ]),
  <fig:TE>,

  figure(image("imgs/modoTMvectores.PNG", width: 4.5cm), caption: [
    Modo de propagación TM
  ]),
  <fig:TM>,

  columns: (1fr, 1fr),
  gap: 0.5cm,
  gutter: 1cm,
  caption: [Modo de propagación transversales],
  label: <fig_modo_propagacion>,
)


// Por otro lado, cuando los campos presentan componentes longitudinales significativas, se habla de modos no TEM.
Por último, siendo este el más propenso a ocurrir en la práctica, aparece el denominado modo cuasi-TEM. Este se trata de un modo de propagación de onda en líneas de transmisión donde los campos eléctrico y magnético son casi, pero no exactamente, perpendiculares a la dirección de propagación.
El modo cuasi-TEM ocurre especialmente en estructuras inhomogéneas producto de que no toda la energía electromagnética queda confinada en la línea de transmisión sino que una parte existe por fuera del sustrato debido a las diferencias entre la permitividad del dieléctrico y el medio que la rodea como es el caso de la línea _microstrip_.

Con el objetivo de simplificar el análisis y dado que el estudio se desarrolla en la región inferior de la banda UHF#footnote[Ultra alta frecuencia (_Ultra High Frequency_). La UIT define UHF como la banda de frecuencias comprendidas entre los 300 MHz y 3GHz], se adoptará la hipótesis de propagación en modos TEM y cuasi-TEM. Esta aproximación resulta adecuada para numerosas líneas de transmisión habitualmente encontradas en la práctica y es especialmente válida para las configuraciones analizadas en este trabajo.

== Características eléctricas
Las líneas de transmisión pueden ser clasificadas, entre otras caracteristicas, por su geometría como así también por las consideraciones eléctricas que se realizan para su análisis como se presenta a continuación.

=== Línea de transmisión sin pérdidas
Representa el caso ideal donde tanto los conductores metálicos como el medio dieléctrico son perfectos. En esta condición, se asume que la resistencia en serie y la conductancia en paralelo son nulas ($R = 0$ y $G = 0$). Como consecuencia, la constante de atenuación es cero ($alpha = 0$), lo que implica que la señal se propaga indefinidamente sin reducir su amplitud

=== Líneas de transmisión largas
Esta clasificación supone que son aquellas líneas de transmisión que se pueden considerar infinitas para el entorno de análisis utilizado, es decir si para un entorno  consideramos la línea como infinita asumiremos que no existen las reflexiones por lo cual toda la energía se llega a transferir a la carga.

=== Línea de transmisión sin distorsión
Es aquella en la que la señal de salida es una réplica exacta de la entrada, atenuada o retrasada, pero sin alterar su forma original.  Como condición para que una línea de transmisión sea tal debe cumplirse la @ec:TL_sin_distorsion poniendo de manifiesto que la velocidad de propagación y la atenuación no dependen de la frecuencia.

$ R/L = G/C $<ec:TL_sin_distorsion>

=== Línea de transmisión de bajas pérdidas
las pérdidas no son nulas pero se consideran pequeñas en comparación con la energía reactiva almacenada por unidad de longitud ($R << omega L$ y $G << omega C$). Esto permite simplificar la constante de propagación $gamma$ y asumir que la impedancia característica $Z_0$ es puramente real, aproximándose a:


#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  $ L dot C approx mu dot epsilon quad -> quad Z_0 approx sqrt(L/C) $, $ sigma/epsilon = G/C $,
)

En @lineasdetransmision se detallan los distintos tipos de línea de transmisión según sus características eléctricas antes mencionadas.


#todo_bib("Agregar referencias a los pdf de clases para esta parte y el pozar")

== Características geómetricas
En lo que respecta a la geometría encontramos las lineas de transmisión planas que son aquellas en las que los conductores que la componen son planos en su forma geométrica. Estas son las más comunes de hallar en una placa de circuito impreso (_PCB_) donde se encuentran conductores paralelos separados por el material dieléctrico #footnote([En el apilamiento (_stack up_) la capa de dieléctrico se la denomina _core_ o _prepeg_ según corresponda]) como podría ser 'FR4', teflón, Kapton, cerámica, RT/Duroid, entre otros.



=== Líneas de transmisión de microcinta o _microstrip_

Una línea _microstrip_ consiste en un _stack-up_ de 2 capas donde la capa superior contiene una pista (linea de transmisión) separada por un  sustrato dieléctrico y en la capa inferior un plano de tierra, tal como ilustra la @fig:microstrip.

#v(-0.6cm)
#figure(
  image("imgs/ilustrations/microstripDespliegue.png", width: 40%),
  caption: [Estructura microstrip],
)<fig:microstrip>


La estructura al estar inmersa entre dos medios materiales podemos afirmar que la señal se propagará por el dieléctrico como así también por el otro medio, en este caso aire. Esta discontinuidad de medios provoca que el campo electromagnético no sea puramente transversal, dando lugar al modo cuasi-TEM antes mencionado. Asimismo, se manifiestan las pérdidas por radiación, ya que una fracción de la energía no queda confinada en el sustrato sino que se radia.
#todo("revisar")
Un parametro importante que debemos mencionar es la permitividad dieléctrica efectiva, esta expresion es consecuencia natural de la forma en la que se encuentra construida nuestra estructura al estar embebida entre dos medios materiales con permitividades dieléctricas relativas diferentes, poniendo de manifiesto que la onda propagante percibirá una permitividad dieléctrica relativa equivalente, cuyo valor se encontrará entre el $epsilon_r$ del aire#footnote[$epsilon_r("aire") = 1,00059 approx 1$] y el $epsilon_r$ del sustrato.

La consecuencia directa de esto, es que todas las ecuaciones donde hasta ahora se utilizaba la constante del material deberan contemplar esta discontinuidad como se muestra en la @ec:vp_eff y @ec:lambda_eff siendo $c_0$ la velocidad de la luz en el vacío y $lambda$ la longitud de onda.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 12pt,
  [$ v_p = c_0 / sqrt(epsilon_r) quad -> quad v_(p_("eff")) = c_0 / sqrt(epsilon_("eff")) $ <ec:vp_eff>],
  [$
    lambda = c_0 / (f dot sqrt(epsilon_r)) quad -> quad lambda_("eff") = c_0 / (f dot sqrt(epsilon_("eff")))
  $ <ec:lambda_eff>],
)

En este sentido, con el objetivo de cuantificar la proporción de campo que viaja por el sustrato frente al que se dispersa,
Wheeler @wheeler1965_filling_factor introduce el concepto de factor de llenado efectivo (_effective filling factor_) en la @ec:filling_factor_wheeler

$ q = (epsilon_("eff")-1)/(epsilon_r -1) $<ec:filling_factor_wheeler>



En trabajos posteriores, Hammerstad @Hammerstad introduce correcciones geometricas para tener una expresión cerrada denotada en la @ec:filling_factor.

$ q=1/2 dot (1+1/sqrt(1+12 dot h\/w)) $ <ec:filling_factor>

Este parámetro pondera geometricamente la relación que tiene la permitividad dieléctrica efectiva del material respecto del vacio. Despejando de la @ec:filling_factor_wheeler podemos relacionar ambos medios mediante la @ec:e_eff_calculo que al sufrir las modificaciones introducidas en la @ec:filling_factor resulta en la @ec:e_eff_despejado.


// Ambos medios se pueden relacionar mediante la @ec:e_eff_calculo la cual al ser desarrollada resulta la @ec:e_eff_despejado.

#grid(
  columns: (1fr, 1.5fr),
  column-gutter: 0pt,
  align: horizon,
  [$ epsilon_("eff") = 1 + q (epsilon_r - 1) $ <ec:e_eff_calculo>],
  [$ epsilon_("eff") = (epsilon_r + 1)/2 + (epsilon_r - 1)/2 dot (1/sqrt(1+12 dot h\/w)) $ <ec:e_eff_despejado>],
)



En @wheeler1965_filling_factor se demuestra que el factor depende de parámetros geométricos de la estructura como lo son la relación entre el ancho de pista ($w$) y el espesor del sustrato ($h$). El uso de esta relación será habitual en posteriores trabajos de otros autores como es el caso de Hammerstad y Jensen, entre otros que desarrollaremos en secciones posteriores de este trabajo.

Para una primera aproximación, si asumimos como constante el $epsilon_r$ del sustrato, es posible notar que el valor de $q$ se encuentra acotado por factores geométricos de la estructura, es decir caso donde la pista es "infinitamente" ancha o infinitesimalmente angosta lo que resulta de que al tomar el límite para el parámetro $h\/w$ sobre la @ec:filling_factor observamos que el valor se encuentra acotado entre $1/2 <= q <= 1$ en consecuencia directa los valores extremos que puede tomar el $epsilon_("eff")$ son $(epsilon_r + 1)/2 <= epsilon_("eff") <= epsilon_r$

#grid(
  columns: (1fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$ lim_(h\/w -> infinity) q--> 1/2 $], [$ lim_(h\/w -> 0) q--> 1 $],
)

Los límites conseguidos poseen una interpretación física respecto a la distribución espacial de las líneas de campo eléctrico. En el caso de una pista infinitesimalmente angosta ($h\/w -> infinity$), el campo se distribuye de manera simétrica y equitativa dado que la mitad viaja por el sustrato y la otra mitad por el aire. Por el contrario, cuando la pista es 'infinitamente' ancha ($h\/w -> 0$), la estructura emula un capacitor de placas paralelas perfecto provocando que la dispersión hacia el aire se vuelve despreciable y la totalidad del campo se confina dentro del dieléctrico lo que fuerza a que $epsilon_("eff") = epsilon_r$. Este último escenario es el caso que da origen a la estructura _stripline_.


=== Líneas de transmisión stripline

Una línea _stripline_ consiste en una forma de construcción de una estructura de línea de transmisión compuesta por tres conductores, ubicandose dos de ellos en el exterior de la misma, separados por materiales dieléctricos de tal forma que el restante conductor queda inmerso en interfaz de contacto de ambas capas dieléctricas. Una ilustración que clarifica lo expresado se observa en la @fig:stripline donde los conductores de los planos superior e inferior son planos de tierra y la banda conductora central se encuentra entre dos dieléctricos que pueden ser de igual o distinta permitividad diélectrica.

#figure(
  image("imgs/ilustrations/striplineDespliegue.png", width: 40%),
  caption: [Estructura stripline],
)<fig:stripline>

La consecuencia inmediata de este "blindaje" es el confinamiento del campo dentro de las fronteras de la estructura. Al no existir una interfaz sustrato-aire, la onda se propaga inmersa en un medio dieléctrico homogéneo. Por lo tanto, si ambos sustratos del 'sandwich' son de iguales caracteristicas ($epsilon_r$), el factor de llenado efectivo es máximo ($q = 1$) y la permitividad percibida por la onda coincide con la del material.

Una de las principales ventajas de la stripline, producto de la homogeneidad de su estructura, es que permite asumir una propagación en modo transversal electromagnético (TEM). Sin embargo en la práctica debido a las imperfecciones del proceso de fabricación en adición a las diferencias geometrícas y de permitividad dieléctrica relativa que tiene cada material que integre el '_stack_' del PCB, el modo de propagación realmente será cuasi-TEM. A pesar de estas limitaciones prácticas, la stripline sigue siendo la geometría plana que presenta la mayor similitud y aproximación al modo TEM ideal.

Por otro lado, la estructura al presentar una forma de 'sandwich' funciona como un blindaje para el conductor central. Esto logra confinar el campo entre las placas exteriores permitiendo despreciar la energía radiada por fuera del sustrato.

Asimismo, como la onda se propaga enteramente por el sustrato, la permitividad efectiva es máxima $epsilon_(e f f) = epsilon_r$ logrando superar al de una _microstrip_ del mismo material lo que conlleva una reducción de la velocidad de fase de la señal como podemos deducir de la @ec:vp_eff lo que reduce la longitud de onda (@ec:lambda_eff) para una misma frecuencia.


// === Fuentes de referencia (links adjuntos) #todo("REVISAR ESTO")
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



== Materiales
Entre los diferentes materiales dieléctricos utilizados como sustrato en la fabricación de placas de circuito impreso (PCB) para alta frecuencia, destacan los cerámicos o teflonados comerciales habitualmente denominados 'tipo Rogers'#footnote[Rogers Corp. es un fabricante de referencia en diseños de alta frecuencia, dado que sus sustratos ofrecen una caracterización eléctrica del sustrato confiable, estable y trazable https://www.rogerscorp.com/] o 'tipo Isola'#footnote[Al igual que Rogers, ofrece laminados con prestaciones notables para aplicaciones de alta velocidad: https://www.isola-group.com/] y los basados en fibra de vidrio comúnmente llamados 'FR4' @globalwell2024fr @raypcb2023fr4 @lee2021advancements @johnson2020comparative. Este último es ampliamente utilizado en circuitos de RF que no requieren prestaciones considerables o se busca un material asequible para trabajar en frecuencias menores a 3GHz; no obstante, a medida que se utiliza cerca de este límite, su desempeño se degrada significativamente debido a diversos factores que se analizarán en las secciones posteriores.
// #todo_compromiso("Hablar de la relación de la tg y er en funcion de la frecuencia")

Cuando hablamos de 'FR4' nos referimos al sustrato dieléctrico que se compone por un tejido de fibra de vidrio dispuesto en un entretramado en forma de malla como se observa en la @fig:malla_fr4, impregnado con resina epoxi que le da el característico color amarillo verdoso (@fig:fr4_lamina). Sobre este laminado se prensa el stack-up definitivo y se laminan las capas de cobre que conformarán las pistas del circuito

Por otra parte, las siglas FR provienen de la denominación _Flame Retardant_ (retardante de llama) Grado 4, lo que indica el cumplimiento de estándares de seguridad ante la inflamabilidad del material bajo la norma UL94 V-0. Esta propiedad autoextinguible se debe principalmente a la composición de la resina epoxi utilizada (habitualmente epiclorhidrina y bisfenol) combinada con agentes retardantes bromados. Ante la presencia de fuego directo, estos aditivos retardan la combustión logrando que el material extinga la llama luego de que elimine la fuente de ignición original.

#subpar.grid(
  figure(image("imgs/ilustrations/laminado_fr4.png", width: 100%, height: 3.5cm, fit: "stretch"), caption: [
    Láminas de FR4 (fibra de vidrio con resina epoxi)
  ]),
  <fig:fr4_lamina>,

  figure(image("imgs/ilustrations/Malla_FR4_MBE.PNG", width: 100%), caption: [
    Tejido de fibra de vidrio entrelazado en un sustrato FR4
  ]),
  <fig:malla_fr4>,

  figure(image("imgs/ilustrations/stackup_4_capas_real.png", width: 100%), caption: [
    Vista de corte del stack-up real de un PCB de 4 capas sobre sustrato FR4
  ]),

  columns: (0.8fr, 0.8fr, 1fr),
  gap: 0.5cm,
  gutter: 0.5cm,
  caption: [Sustrato FR4 en vistas macroscópica y microscópica],
  label: <fig:polarizacion_dielectrico>,
)

Desde el punto de vista eléctrico, particularmente en su uso y diseño de circuitos de alta frecuencia, nos resultan de interés algunos parámetros del FR4 que lo caracteriza como lo son su permitividad relativa ($epsilon_r$) y su tangente de pérdidas ($tan (delta)$), sin embargo antes de continuar deberemos profundizar en la definición de estos parámetros pues de ellos dependerá el correcto diseño y simulación como así también su posterior implementación.

=== Permitividad dieléctrica

La permitividad dieléctrica ($epsilon$) es una propiedad de los materiales dieléctricos que cuantifica su capacidad para polarizarse cuando son sometidos a un campo eléctrico. En ausencia de un campo externo, los momentos dipolares del material están orientados al azar, de modo que el momento dipolar es nulo, como se ilustra en la @fig:di_no_pol . Sin embargo, cuando se aplica un campo eléctrico estas cargas experimentan pequeños desplazamientos respecto de su posición de equilibrio; originando dipolos eléctricos inducidos capaces de almacenar energía en el medio como se ilustra  en la @fig:di_pol.

#subpar.grid(
  figure(image("imgs/ilustrations/dielectricoNoPolTAND.PNG", width: 100%), caption: [
    PCB no polarizado
  ]),
  <fig:di_no_pol>,

  figure(image("imgs/ilustrations/dielectricoSIPolTAND.PNG", width: 100%), caption: [
    PCB polarizado
  ]),
  <fig:di_pol>,

  columns: (1fr, 1fr),
  gap: 0.5cm,
  gutter: 2cm,
  caption: [Polarización del sustrato del PCB],
  label: <fig:polarizacion_dielectrico>,
)

La orientación de estos dipolos se describe mediante el vector polarización $arrow("P")$, el cual representa el momento dipolar eléctrico por unidad de volumen.

Al someter el dieléctrico a un campo eléctrico $arrow("E")_("aplicado")$, los dipolos del material se alinean y producen una acumulación de cargas de polarización en las superficies. Estas cargas producen un campo de polarización $arrow("E")_("polarización")$ en sentido opuesto al campo aplicado. Como consecuencia, el módulo del campo eléctrico efectivo dentro del dieléctrico disminuye y puede expresarse con en la @ec:campo_electrico_total.

$ |arrow("E")_("total")| = |"E"_("aplicado")| - |"E"_("polarización")| $<ec:campo_electrico_total>

En un medio dieléctrico lineal, la polarización es proporcional al campo eléctrico aplicado, donde $epsilon_0$ es la permitividad del vacío y $chi_e$ la susceptibilidad eléctrica#footnote("En el caso general de materiales anisotrópicos,  la susceptibilidad  " + $chi_e$ + " es una matriz de tensores, cuyo campo de análisis excede el alcance del presente trabajo. Sin embargo,  al asumir un medio lineal,  isotrópico y homogéneo,  dicha matriz se reduce  a una constante.") del material presentado en la @ec:vec_polarizacion.

$ arrow("P") = epsilon_0 dot chi_e dot arrow("E")_("aplicado") $<ec:vec_polarizacion>


Asi mismo, se define el vector desplazamiento $arrow("D") = epsilon_0 dot arrow("E") + arrow("P")$, que al reemplazar $arrow("P")$ mediante la   @ec:vec_polarizacion y asumiendo un medio lineal, isotrópico y homogéneo obtenemos la @ec:vector_desplazamiento

$
  arrow("D") =epsilon_0 dot (1+ chi_e) dot arrow("E") -->arrow("D") =epsilon dot arrow("E")
$<ec:vector_desplazamiento>

Finalmente, la permitividad dieléctrica del material puede ser expresada en la @ec:permitividad_con_epsilon_r,  donde $epsilon_r$ es la permitividad relativa del material respecto del vacío.

$ epsilon = epsilon_r dot epsilon_0 $<ec:permitividad_con_epsilon_r>

Hasta este punto se ha considerado que la permitividad relativa ($epsilon_r$)  permanece constante en su valor. Sin embargo, en la práctica esta propiedad depende de diversos factores que alteran el mismo.

El primero es la dependencia con la frecuencia; a medida que esta aumenta, los dipolos pierden la capacidad de orientarse con el campo eléctrico, por lo que la permitividad varía, ocasionando que algunos mecanismos de polarización dejen de seguir las variaciones del campo eléctrico debido a sus tiempos de relajación. En consecuencia, disminuye la polarización total del material y, por ende la permitividad del dieléctrico también lo hace.

En las hojas de datos (datasheets) provistas por los fabricantes se suele dar un valor único y considerado constante típicamente a #qty[1][GHz]. Aunque a frecuencias mayores, como lo son aplicaciones de microondas o alta velocidad, la permitividad decae.


El segundo es la dependencia espacial: debido al proceso de fabricación los materiales dieléctricos no son homogéneos ni isotrópicos. En particular en el FR4 la estructura del tejido de fibra de vidrio y las imperfecciones de manufactura introducen una anisotropía que provoca que sus parámetros característicos exhiban sensibilidad conforme a la dirección en que son analizados.


Además, como señala Pozar en #cite(<Pozar>, supplement: [p.  10]),  el valor de la permitividad de estos materiales pertenece al campo complejo, como  se expresa en la @ec:epsilon_complejo.

$ epsilon = epsilon^' -j dot epsilon^'' $<ec:epsilon_complejo>

La parte real de la permitividad ($epsilon^'$) se relaciona con la definición expresada previamente, la cual cuantifica la capacidad del dieléctrico para polarizarse cuando este es sometido a un campo eléctrico.

La parte imaginaria de la permitividad  $epsilon^''$ representa las pérdidas del medio, debido al amortiguamiento de los momentos dipolares en vibración. En contraparte, el espacio libre al poseer una permitividad ($epsilon_0$)  puramente real no presenta estas pérdidas.

#figure(image("imgs/ilustrations/permitividad_compleja_modelo.png", width: 40%), caption: [
  Comportamiento tipico de la parte real ($epsilon^'$) y la parte imaginaria ($epsilon^''$) de la permitividad del material
])<fig:modelo_grafico_epsilon_complejo>

Como se ilustra en la @fig:modelo_grafico_epsilon_complejo, cuando la curva asociada a la parte real ($epsilon^'$) experimenta un rápido decaimiento, la parte imaginaria ($epsilon^''$) aumenta en valor logrando alcanzar máximos para iguales frecuencias producto de los mecanismos de relajación dipolar del material dieléctrico.

A bajas frecuencias, los dipolos del material pueden alinearse sin mayor dificultad con el campo eléctrico aplicado logrando mantener un valor de $epsilon^´$ constante. Conforme aumenta la frecuencia los mecanismos de polarización no logran seguir la velocidad de cambio del campo eléctrico provocando la disminución del $epsilon^'$ y la aparición de picos asociados a resonancias de $epsilon^''$ producto del amortiguamiento y pérdidas por relajación dipolar.

Las frecuencias asociadas a dichos máximos serán en las que el material presentará las mayores disipaciones de energia.

En consecuencia se presenta una relación entre la parte real y compleja de la permitividad mediante @ec:permitividad_con_tangente donde se introduce el termino de la tangente de pérdidas ($tg(delta)$).


$ epsilon = epsilon^' dot (1- j dot tg(delta)) $ <ec:permitividad_con_tangente>

=== Tangente de pérdidas

La tangente de pérdidas o tangente delta ($tg(delta)$) cuantifica la energía disipada en el dieléctrico debido a los procesos de polarización del material.

En un dieléctrico, la disipación total proviene de dos factores; las pérdidas por amortiguamiento dipolar del mismo ($omega epsilon^''$) y las pérdidas por conductividad ($sigma$). Dado que ambos producen el mismo efecto disipativo sobre la onda electromagnética no es posible distinguirlos. En consecuencia el término $omega epsilon^'' + sigma$ se puede considerar como la conductividad total, lo que permite definir la tangente delta ($tg(delta)$) mediante la @ec:tangente_con_sigma.

// por lo que la tangente delta ($tg(delta)$) se describe en la @ec:tangente_con_sigma.

// Como las pérdidas por amortiguamiento dipolar del dieléctrico ($omega epsilon^''$) son indistinguibles de la pérdida por conductividad ($sigma$) , el término  $omega epsilon^'' + sigma$ puede considerarse como la conductividad efectiva total, por lo que la tangente delta se describe en la @ec:tangente_con_sigma.

$ tg(delta) = (omega dot epsilon^'' + sigma) / (omega dot epsilon^') $<ec:tangente_con_sigma>





// Asi mismo, la rugosidad de las capas de cobre puede incrementar las pérdidas por conducción, especialmente a frecuencias del orden de los GHz. A pesar de ello, cierta rugosidad es necesaria para asegurar una adecuada adhesión entre el cobre y el sustrato dieléctrico durante el proceso de fabricación del PCB.

Sin embargo, asumiendo un dieléctrico sin pérdidas ($sigma approx 0$),  la expresión de la tangente delta ($tg(delta)$) se reduce a la @ec:tangente_delta_sin_sigma.

// Asumiendo un dieléctrico sin pérdidas por conductividad, la tangente delta ($tg(delta)$) se expresa como en la @ec:tangente_delta_sin_sigma.

$ tg(delta) = epsilon^''/ epsilon^' $<ec:tangente_delta_sin_sigma>

Por otro lado, como se mencionó anteriormente, en la práctica los dieléctricos como el FR4 no son homogéneos ni isotrópicos, lo que afecta a parámetros de diseño, como la impedancia característica y la velocidad de propagación.

A pesar de estas limitaciones, el FR4 es el material seleccionado para este trabajo debido a su bajo costo, amplia disponibilidad y facilidad de fabricación, convirtiéndolo en una opción adecuada para la implementación de estructuras de microstrip y para la caracterización experimental de parámetros dieléctricos. Si bien su naturaleza inhomogénea puede introducir pequeñas variaciones en los resultados, para la frecuencia de trabajo de #qty[915][MHz] el material sigue siendo adecuado para el análisis y validación de los métodos de caracterización propuestos.

== Mediciones
#todo("REVISAR todo este capitulo pues tiene cosas redactadas raras")

Para caracterizar experimentalmente las estructuras _microstrip_ presentadas en este trabajo, los cuales son _stubs_, resonadores de anillo y acopladores direccionales, se emplea el análisis mediante parámetros de dispersión. Estos permiten describir el comportamiento de un dispositivo de múltiples puertos en términos de ondas incidentes y reflejadas en cada uno de sus puertos.

=== Parámetros S

En circuitos de microondas, el análisis de redes se realiza comúnmente mediante parámetros de dispersión, también conocidos como parámetros S.

// #v(-0.5cm)
#figure(
  image("imgs/ilustrations/cuadripolo.png", width: 50%),
  caption: [Modelo de cuadripolo (parámetros S)],
)<fig:cuadripolo_parametros_s>

El cuadripolo de la @fig:cuadripolo_parametros_s se conforma por dos puertos. El primero de ellos está integrado por los polos $A_1$ y $B_1$,
que representan la onda incidente y reﬂejada respectivamente; de manera similar en el segundo puerto el polo A2 representa a la onda incidente
y el polo B2 la onda  reﬂejada. Es importante mencionar que cada uno de los
puertos puede absorber, reﬂejar o transmitir la señal.

Los parámetros de dispersión se definen como la relación entre la onda que sale de un puerto y la onda que incide en otro, manteniendo todos los demás puertos adaptados a la impedancia característica del sistema. Estos se representan con la letra S seguido de un subíndice de dos dígitos ($S_(i j)$), el primero de ellos indica el puerto de salida (donde se mide) y el segundo el puerto de entrada (donde se aplica el estímulo). Por ejemplo, si se aplica el estímulo en el puerto 1 y se mide en el puerto 2, se obtiene parámetro *$S_(21)$*

Las relaciones entre los polos de cada uno de los puertos nos darán como resultado estos
parámetros.

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$ S_(1 1) = lr(B_1 / A_1 |)_(A_2 = 0) $ ],
  [$ S_(1 2) = lr(B_1 / A_2 |)_(A_1 = 0) $],
  [$ S_(2 1) = lr(B_2 / A_1 |)_(A_2 = 0) $],
  [$ S_(2 2) = lr(B_2 / A_2 |)_(A_1 = 0) $],
)






Los parámetros S pueden representarse en forma matricial, con $n^2$ elementos para $n$ puertos. Para un dispositivo de cuatro puertos, como el acoplador direccional analizado de trabajo, la red se podría ser descripta mediante una matriz de dispersión de 4×4 , donde cada elemento corresponde a una relación de transmisión o reflexión entre dos puertos

// $
//   mat(
//     S_(1 1), S_(1 2), S_(1 3), S_(1 4);
//     S_(2 1), S_(2 2), S_(2 3), S_(2 4);
//     S_(3 1), S_(3 2), S_(3 3), S_(3 4);
//     S_(4 1), S_(4 2), S_(4 3), S_(4 4);
//   )
// $<ec:matriz_s>

Cada uno de estos parámetros tiene un sentido propio y nos permiten conocer parámetros tales
como la ganancia, impedancia, VSWR, pérdidas de inserción, entre otros. Veamos que representa cada uno de ellos en nuestro caso bipuerto y que podemos obtener a partir
de estas características base.

*Coeficientes de reflexión*

- $S_("11")$:  *Coeficiente de reflexión  en la entrada* ($Gamma_("in")$) → Pérdidas por retorno (expresadas en dB)
- $S_("22")$:  *Coeficiente de reflexión en la salida* ($Gamma_("out")$) → Pérdidas por retorno (expresadas en dB)

*Coeficientes de transmisión*

- $S_("12")$:  *Coeficiente de transmisión inversa*  → Pérdidas por inserción (expresadas en dB)
- $S_("21")$:  *Coeficiente de transmisión directa* → Pérdidas por inserción (expresadas en dB)


// El uso de parámetros S resulta especialmente conveniente en frecuencias de microondas, ya que permite caracterizar experimentalmente el dispositivo mediante instrumentos como el analizador de redes vectorial (VNA), el cual mide directamente estos parámetros en función de la frecuencia. En la siguiente sección se describirá el principio de funcionamiento de este instrumento y su utilización para la medición de los dispositivos desarrollados en este trabajo.

=== Analizador de redes vectoriales (VNA)

Un *VNA* es un instrumento que permite medir los parámetros S mencionados previamente; sin embargo, veamos con mayor detalle
la obtención de los parámetros en una red de dos puertos.

El VNA caracteriza los parámetros S del dispositivo inyectando una señal de estímulo en uno de los puertos del DUT#footnote("Al momento de realizar una medición habitualmente al dispositivo a ensayar o caracterizar se lo denomina
DUT.") (Device Under Test) mientras que el otro  se adapta con una carga (típicamente de $50 Omega$) si se mide reflexión. Acto seguido, mide la relación entre la onda reﬂejada e incidente en el *puerto 1*, dando como resultado el parámetro $S_("11")$.por otro lado si se
evalúa la relación entre la onda transmitida del puerto 1 al 2 se obtiene el parámetro $S_("21")$ (transmisión directa). De manera similar, si se invierte el DUT (estímulo en el puerto 2 y carga en el puerto 1), se adquiere el $S_(22)$ (reflexión en el puerto 2) y $S_(12)$ (transmisión inversa). Es importante recordar que los parámetros S se expresan en módulo (dB) y fase (grados).

=== Calibración del VNA

Antes de cualquier medición es importante  siempre realizar una calibración con el
objetivo de mitigar los errores sistemáticos de origen instrumental, cables y conectores. La calibración básica de un VNA es la calibración tipo SOLT, la cual es la sigla para “*short*” ( cortocircuito), “*open*” (circuito Abierto), “*load*” (carga) y “*through*” (inter-puerto). Habitualmente esta se realiza mediante el software de calibración provisto por el fabricante del instrumento. Las tres primeras instancias (*cortocircuito*, *circuito abierto* y *carga* de 50 Ω) permiten corregir los errores en la medición de coeficientes de reflexión, mientras que la instancia *through* es fundamental para corregir los errores en la medición de coeficientes de transmisión.

#subpar.grid(
  show-sub-caption: 10pt
)

#v(-.62cm)
#subpar.grid(
  figure(image("imgs/calibracion_vna.jpg", width: 100%, height: 3.5cm, fit: "stretch"), caption: [
    Banco de calibración
  ]),
  figure(
    image("imgs/ilustrations/torquimetrica.png", width: 100%, height: 3.5cm, fit: "stretch"),
    caption: [Ejemplo de llave torquimétrica],
  ),
  figure(
    image("imgs/ilustrations/solt_kit.png", width: 100%, height: 3.5cm, fit: "stretch"),
    caption: [Kit de calibración SOLT (SMA)
    ],
  ),

  columns: (1fr, 1fr, 1fr),
  gutter: 1cm,
  gap: 0.5cm,
  caption: [Calibración del VNA],
  label: <fig:calibración>,
)

La calibración desplaza el plano de referencia hasta los conectores del DUT, eliminando así los errores sistemáticos del instrumento y de los cables. Para garantizar la repetibilidad y evitar daños en los conectores, se recomienda utilizar llaves torquimétricas para ajustar las conexiones y limpiar las superficies con alcohol isopropílico antes de cada medición.


== Modelos de análisis

En este trabajo se consideraron tres modelos que nos permitiran caracterizar el sustrato: el modelo cuasi-estático de Hammerstad y Jensen, el modelo de dispersión de Kirschning y Jansen, y el modelo de Debye de Djordjevic-Sarkar para la permitividad compleja del dieléctrico.

=== Modelo de Hammerstad y Jensen (cuasi-estático)
El modelo de Hammerstad y Jensen @Hammerstad para _microstrips_ nos proporciona una expresión cerrada para el cálculo de la permitividad efectiva y la impedancia característica en función de su geometría y de las propiedades del sustrato. El modelo introduce correcciones por geometría considerando el espesor del conductor, lo que mejora la precisión en el cálculo de los parámetros de la línea.
En la @fig:error_hj se presenta una comparativa del error relativo de este modelo frente a otros modelos para un valor fijo de $epsilon_r$ dado poniendo de manifiesto su precisión y menor error respecto de otras fórmulas @ahn2012microstrip_error_hj @qucs_single_microstrip.

#figure(
  image("imgs/error_modelo_hj.png", width: 60%),
  caption: [Error relativo de diferentes modelos para la impedancia caracteristica ($epsilon_r = 9.8$)],
)<fig:error_hj>


El modelo se basa en el la definición del parámetro $u = W/h$, que representa una normalización del ancho de la pista respecto de la altura del sustrato. A partir de este parámetro, se definen dos funciones auxiliares $a(u)$ y $b(epsilon_r)$, que modelan la dependencia de la permitividad efectiva con la geometría y el material.

$ a(u) = 1+ 1/49 dot ln((u^4 + (u/52)^2)/(u^4 + 0.432)) + 1/18.7 dot ln(1 + (u/18.1)^3) $

$ b(epsilon_r) = 0.564 dot ((epsilon_r - 0.9)/(epsilon_r + 3))^0.053 $

Haciendo uso de ellas se calcula la permitividad efectiva para el caso ideal donde el espesor del conductor es nulo ($t = 0$) mediante la @ec:epsilon_eff_hammerstad_sin_t

$
  epsilon_("eff")(u,epsilon_r) = (epsilon_r+1)/2 + (epsilon_r-1)/2 dot (1 + 10 /u)^(-a(u) b(epsilon_r))
$<ec:epsilon_eff_hammerstad_sin_t>


Como fue mencionado anteriormente, el modelo permite calcular la impedancia característica en un medio homogéneo, esto se realiza mediante la @ec:impedancia_hammerstad_sin_t. La expresión incluye la función $f(u)$, que modifica el término logarítmico en función de la relación $W/h$, siendo $eta_0$ la impedancia del vacío $eta_0 approx 377 Omega$.

$ f(u) = 6 + ( 2 pi - 6) dot exp(-(30.666 / u)^0.7528) $


$ Z_(01) (u) = eta_0/ (2 pi ) dot ln(f(u) /u + sqrt(1 + (2/u)^2)) $<ec:impedancia_hammerstad_sin_t>



Para considerar el espesor del conductor ($t$),     Hammerstad y Jensen introducen correcciones en el ancho efectivo de la línea ($u$) mediante dos factores:
$Delta u_1$ para el cálculo de un medio homogéneo  y $Delta u_r$ para un medio mixto. Dichos factores se definen como:



#grid(
  columns: (1.05fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$ Delta u_1 = t/pi ln(1 + (4 exp(1))/(t dot (coth sqrt(6.517 dot u))^2)) $],
  [$ Delta u_r = 1/2 (1 +1 /(cosh(sqrt(epsilon_r - 1))) dot Delta u_1) $],
)

A partir de estas correcciones, se definen los anchos efectivos con corrección como: $u_r = u + Delta u_r$ y $u_1 = u + Delta u_1$.


Combinando las correcciones por espesor con la impedancia $Z_(01)$, se obtienen las expresiones finales para la permitividad efectiva mediante la @ec:epsilon_eff_hammerstad y la impedancia característica con la @ec:impedancia_hammerstad de la línea _microstrip_. Estas expresiones son válidas en el régimen cuasi-estático y son la base de la que partiremos para el diseño de las líneas _microstrip_ antes de considerar efectos dispersivos.



#grid(
  columns: (1.05fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$
    epsilon_("eff")(u,t,epsilon_r) = epsilon_("eff")(u_r,epsilon_r) dot ((Z_(01) (u_1))/ (Z_(01)(u_r)))^2
  $<ec:epsilon_eff_hammerstad>],
  [$ Z_0 (u,t,epsilon_r)= (Z_(01) (u_r) )/( sqrt(epsilon_("eff")(u_r, epsilon_r))) $<ec:impedancia_hammerstad>],
)

=== Modelo de Kirschning y Jansen (dispersión)

El modelo cuasi-estático de Hammerstad y Jensen, descrito en el apartado anterior, no incluye la dependencia de los parámetros de la línea con la frecuencia. Para incorporar los efectos de la dispersión, se utiliza el modelo de Kirschning y Jansen @Kirschning, el cual proporciona una expresión para la permitividad efectiva en función de la frecuencia.

$ epsilon_("eff")(f) = epsilon_r - ((epsilon_r - epsilon_("eff")(f=0))/(1 + P(f))) $<ec:epsilon_eff_Kirschning>

Este modelo parte del valor de la permitividad efectiva en régimen  cuasi-estático $epsilon_("eff")(f=0)$ calculada mediante el modelo de Hammerstad y Jensen, y la corrige mediante un factor empírico de dispersión $P(f)$ que depende de la frecuencia y de la geometría de la línea mediante la @ec:epsilon_eff_Kirschning donde el factor $P(f)$ se define como:

$ P(f)= P_1 dot P_2 dot [(0.1844 + P_3 dot P_4) dot 10 dot f dot h]^1.5763 $

donde las funciones P1, P2, P3 y P4 vienen dadas por:

$P_1 = 0.27488 + [0.6315 + 0.525/(1+ 0.157 dot f dot h)^20] u - 0.065683 exp(-8.7513 dot u)$

$P_2 = 0.33622 [1-exp(- 0.03442 epsilon_r)]$

$P_3 = 0.0363 exp(-4.6 dot u) dot {1- exp[-((f dot h)/3.87)^4.97]}$

$P_4 = 1 + 2.751 {1- exp[-(epsilon_r/15.916)^8] }$


Es importante mencionar que en estas expresiones, f se expresa en gigahertz (GHz), h en centrimetros (cm) y el parámetro $u=W/h$ es la relación entre el ancho de la pista y la altura del sustrato, definida previamente en el modelo de Hammerstad y Jensen.




=== Modelo de Djordjevic - Sarkar (modelo Debye del diélectrico)
#todo("TODO lo de este modelo hay que revisar lo que se escribio")

Los modelos presentados anteriormente (Hammerstad y Jensen, Kirschning y Jansen) describen la permitividad efectiva de la línea microstrip en función de la geometría y la frecuencia, pero no modelan la permitividad dieléctrica del material en función de la frecuencia. Como se mencionó previamente mediante la ecuación @ec:epsilon_complejo, la permitividad es una magnitud compleja y se puede expresar como la @ec:epsilon_con_delta.
$
  epsilon = epsilon' dot (1 - j dot tan(delta))
$<ec:epsilon_con_delta>

El modelo Debye establece que la respuesta en frecuencia del material debe ser causal. Cuando hablamos de causalidad de un material nos referimos a que este cumple las condiciones de Kramers-Kronig #todo("citar kramer-kronig") las cuales indican que la respuesta del material a una excitación no puede ocurrir antes de la excitación misma.

El modelo Debye clásico sobre el que se desarrolla, si bien cumple la causalidad es valido en un rango acotado frente a la extensión que propone el modelo Sarkar pues en el modelo clasico presentado en la @ec:debye_clasico se tiene un solo tiempo de relajación que responde a un rango acotado de frecuencias y si se quisiera extender se deberia sumar N términos de tiempos de relajación como en la @ec:debye_clasico_n_terms lo que complejizaría la operación con el modelo.

#grid(
  columns: (1.05fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$
    epsilon_r^* (omega) = epsilon_infinity + Delta_epsilon/(1+j dot omega dot tau)
  $ <ec:debye_clasico>],
  [$
    epsilon_r^* (omega) = epsilon_infinity + sum_(i=1)^N (Delta_epsilon/(1+j dot omega dot tau_i))
  $ <ec:debye_clasico_n_terms>],
)

Djordjevic y Sarkar observaron que para muchos sustratos, como el FR-4, la distribución de tiempos de relajación no es discreta, sino continua, uniforme y en forma logarítmica. Para modelar este comportamiento #todo("aca continuar con la explicacion")
// $epsilon_r (omega) = epsilon'_(infinity) + sum_(i=1)^(N) (Delta epsilon_i)/(1 + j omega/ omega_i) - j sigma / (omega  epsilon_0)$

$ k = log((f_("high")+ j dot "freq" ) / (f_("low") + j dot "freq")) $

$ f_d = log((f_("high") + j dot f)/(f_("low") + j dot f)) $

$ "ep"_"d" = -tg(delta) dot epsilon_r / Im(k) $

$ epsilon_(infinity) = epsilon_r dot (1+ tg(delta) dot Re(k)) / Im(k) $

$ epsilon_r = epsilon_(infinity) + "ep"_"d" dot f_d $
#todo("revisar el modelo para ver si es correcta la implementacion e introducir el despeje que hizo Kar y el motivo de porque es conveniente hacerlo de esa forma pues tenemos los datos de lo que sacamos antes de la tg_delta y epr_eff")




== Aplicaciones

En esta sección se presentan algunas aplicaciones prácticas de los conceptos desarrollados previamente sobre líneas de transmisión. Antes del análisis de cada caso, se realizará una breve explicación teórica de cada dispositivo para comprender el principio de su funcionamiento.

En particular, se estudiarán stubs, resonadores de anillo y acopladores direccionales, los cuales son dispositivos utilizados en circuitos de radiofrecuencia y microondas implementados sobre PCBs.

=== Stubs

Un stub es una línea de transmisión de longitud finita terminada en circuito abierto o en cortocircuito. Su principal característica es que presenta una impedancia que depende tanto de su longitud eléctrica como del tipo de terminación. La @fig:stubs_dibujo ilustra un conjunto de stubs con terminación en circuito abierto, utilizado en este trabajo para la caracterización del sustrato FR4 y la obtención de sus parámetros característicos..


#figure(
  image("imgs/ilustrations/stubs_dibujo.png", width: 45%),
  caption: [Stubs],
)<fig:stubs_dibujo>

Para un stub con terminación en circuito abierto ($Z_L = infinity$), la impedancia está dada por la @ec:stub_abierto.


$ Z(l)= -j dot Z_0 dot cot(beta dot l) $<ec:stub_abierto>

Por otro lado, cuando el stub tiene una terminación en cortocircuito ($Z_L= 0$), la impedancia se expresa mediante la @ec:stub_corto.

$ Z(l) = j dot Z_0 dot tan(beta dot l) $<ec:stub_corto>

#subpar.grid(
  figure(plot_z_stub_vs_l(navy, red, 0, is_open_stub: true), caption: [Stub con terminación en circuito abierto]),
  <fig:open_stub>,

  figure(
    plot_z_stub_vs_l(navy, fuchsia, calc.pi / 2.0, is_open_stub: false),
    caption: [Stub con terminación en cortocircuito],
  ),
  <fig:short_stub>,

  columns: (1fr, 1fr),
  gap: 0.5cm,
  gutter: -0cm,
  caption: [Impedancia del stub en función de $beta l$],
)

Las curvas de la @fig:open_stub y la @fig:short_stub permiten observar cómo varía la impedancia del stub en función de su longitud eléctrica para ambos tipos de terminación. A partir de este comportamiento surgen diversas aplicaciones, siendo las más comunes la adaptación de impedancias donde se emplea para compensar la parte reactiva de una carga y lograr la máxima transferencia de potencia como así también el diseño de filtros de microondas, en los que actúa como un elemento reactivo implementado directamente sobre el PCB, entre otras.

Otra aplicación relevante es la caracterización de dieléctricos, ya que es posible estimar la permitividad efectiva del sustrato sobre el cual se implementa la línea de transmisión. Esto resulta particularmente útil para el análisis y validación de materiales utilizados.

Para esta aplicación, la longitud física del stub se diseña a un cuarto de longitud de onda ($lambda/4$) asociada a la frecuencia de resonancia $f$, como se expresa en la @ec:longitud_stub, donde $L$ es la longitud física, $c_0$ es la velocidad de la luz en el vacío y $epsilon_("eff")$ es la permitividad efectiva del sustrato.

// Para esta última aplicación, se analizan las condiciones de resonancia de un stub. En términos generales pueden expresarse mediante la longitud física del mismo como la @ec:longitud_stub, donde $L$ es la longitud física del stub, f es la frecuencia de resonancia, $epsilon_("eff") $ es la permitividad efectiva del sustrato y n reperesenta el armónico.

$ L = lambda/4 = c_0/(4 dot f dot sqrt(epsilon_("eff")) ) $<ec:longitud_stub>

Las condiciones de resonancia ocurren en los puntos donde la impedancia de entrada del stub se anula ($Z_("in")=0$), haciendo que la línea se comporte como un cortocircuito a la frecuencia de interés. Por otro lado, la antiresonancia ocurre cuando la impedancia de entrada del stub se hace infinita ($Z_("in")=infinity$).

En un stub con terminación en circuito abierto, como se observa en la @fig:open_stub,  las resonancias ocurren para los armónicos impares $(n=1,3,5,...)$, cumpliendose la @ec:resonancia_open_stub. Por su parte, las antiresonancia ocurren en armónicos pares $(n=2,4,6,...)$

$ beta dot l = (2k + 1) dot pi / 2 --> n = 2k + 1 $<ec:resonancia_open_stub>

Para un stub con terminación en cortocircuito, observando la @fig:short_stub, las resonancias ocurren para los armónicos pares ($n = 2, 4, 6,dots$), tal como se indica en la @ec:resonancia_short_stub.

$ beta dot l = 2k dot pi / 2 --> n = 2k $<ec:resonancia_short_stub>

De manera complementaria, las antiresonancias ($Z_("in") -> infinity$) para este stub en cortocircuito ocurren en los armónicos impares ($n = 1, 3, 5, dots$), lo que corresponde a los puntos donde la tangente tiende a infinito por lo tanto la impedancia también.


// Para dos stubs de diferentes longitudes se obtinen:

// #grid(
//   columns: (1fr, 1fr),
//   column-gutter: 8pt,
//   $ L_1 = n dot lambda_1/4 =(n dot c_0)/(4 dot f_1 dot sqrt(epsilon_(e f f)) ) $,
//   $ L_2 =n dot lambda_2/4 = (n dot c_0)/(4 dot f_2 dot sqrt(epsilon_(e f f))) $,
// )

// Donde $L_1$ y $L_2$ son las longitudes físicas de los stubs, $f_1$ y $f_2$ son sus respectivas frecuencias de resonancia, y $n$ es un número entero que corresponde al armónico del modo de resonancia analizado (el cual debe ser el mismo para ambos stubs).

// Cabe destacar que en un stub con terminación en circuito abierto, las condiciones de resonancia se dan cuando $beta dot l = (2k + 1) pi / 2$. Como se puede observar en la @fig:open_stub , en estos valores la impedancia se anula y el stub se comporta como un cortocircuito hacia la línea principal, haciendo que las resonancias ocurran en los armónicos impares ($n = 1, 3, 5, ...$).

// Por el contrario, un stub con terminación en cortocircuito resuena cuando $beta dot l = k dot pi$ y $l = n dot lambda/4$. En la @fig:short_stub se aprecia que en estos puntos la impedancia también se hace cero. Bajo esta condición, su entrada se comporta como un cortocircuito, por lo que las resonancias aparecen en los armónicos pares ($n = 2, 4, 6, ...$).


// Restando ambas expresiones se obtiene:
// $ L_2- L_1 = (n dot c_0)/(4 dot sqrt(epsilon_(e f f))) dot (1/f_2- 1/f_1) $

// Despejando el $epsilon_("eff")$

// $ epsilon_("eff") = ((n dot c_0)/(4 dot (L_2-L_1)))^2 dot (1/f_2- 1/f_1)^2 $<ec:eff_stubs>

=== Anillos resonantes

// Un resonador de anillo es una estructura formada por una línea de transmisión cerrada sobre sí misma, cuya longitud eléctrica permite la formación de condiciones de resonancia bien definidas. Este tipo de estructuras ha sido ampliamente utilizado en circuitos de microondas y radiofrecuencia.

// #todo("REFERENCIAR LA TESIS DE BOGGI")

// Para complementar el análisis de la resonancia, en @wu_mode_chart, Wu y Rosenbaum analizan los distintos modos de propagación mediante un _mode_ _chart_, el cual es un gráfico que relaciona la frecuencia con el ancho normalizado del anillo ($"W"/R_("med")$), donde se pueden observar los distintos modos de resonancia en función de las dimensiones del anillo.

// Los modos de resonancia se denominan $T M_("nml")$, $T M$ corresponde a transversal magnético (definido anteriormente), el índice n es la variación azimutal (alrededor del anillo), la cual indica cuántas longitudes de onda completas se distribuyen a lo largo de la circunferencia del anillo, el índice m es la variación radial y el índice l indica la variación en altura de la onda. Dado que el sustrato es tan delgado que el campo no varía en altura, casi siempre será $l = 0$.

// Partiendo de la condición de resonancia de Troughton (@ec:resonancia_anillo) y expresándola en función del número de onda $(k=2pi/lambda)$ se obtiene la @ec:aproximacion_con_k.

// $ k R_("med") = n $<ec:aproximacion_con_k>

// Esta ecuación indica que la fase acumulada de la onda al dar una vuelta completa al anillo debe ser $2 pi n$. Sin embargo, como advierten Wu y Rosenbaum, esta igualdad es válida para anillos de ancho angosto $("W"/R_("med") -->0)$. En este caso, el campo viaja en una dirección (la circunferencia) y no hay variación radial, por lo que el modo es puramente $T M_("n10")$. Cuando el anillo es ancho, aparecen variaciones del campo en la dirección radial, lo que da lugar a modos de alto orden (modos con $m>1$) y efectos de borde que modifican la frecuencia de resonancia; como consecuencia, el valor de $k R_("med")$ es menor que n para un modo dado. Además, si el anillo alcanza la aproximadamente la mitad de la longitud de onda a la que fue diseñado, comienzan a aparecer variaciones en la dirección radial y aparecen dischos modos de alto orden.


// A partir de esta clasificación, en @wu_mode_chart Wu y Rosenbaum muestran que el modo $T M_("110")$ es el dominante para cualquier ancho de anillo. Sin embargo, para anillos anchos pueden aparecer modos de orden superior; esto debe evitarse, ya que la aproximacionn de Trougton no es válida para modos de alto orden. Para ello, Wu y Rosenbaum establecen que para evitarlo se debe cumplir $"W"/R_("med") <= 0.1$.

// Para aplicaciones prácticas, se busca operar en el modo fundamental, típicamente el modo $T M_(110)$
// , ya que presenta una distribución de campos más simple y una respuesta más predecible. Sin embargo, la excitación de modos superiores puede ocurrir dependiendo de la geometría del resonador, lo cual es necesario evitar ya que los modos superiores o modos de alto orden pueden generar resonancias intermedias por lo que la caracterización del sutrato para  este modelo no seria valido.


// termina resultando que $w/R_(m e d) <= 1$, es decir un "anillo fino" para que el anillo no tenga modos de alto orden.

Un resonador de anillo está compuesto por un anillo y dos líneas de alimentación (_feed_ _lines_), como se ilustra en la @fig:ring_dibujo. Las _feed_ _lines_ permiten transferir potencia hacia el resonador y extraerla desde él. Dichas líneas se encuentran separadas del anillo por una distancia denominada _gap_.

#figure(
  image("imgs/ilustrations/ring_resonator_dibujo.png", width: 50%),
  caption: [Esquema básico de un resonador de anillo],
)<fig:ring_dibujo>

En #cite(<Ring_resonator>, supplement: [p.  6-7]) Chang describe que el valor del _gap_ resulta crítico para el comportamiento del sistema, ya que determina el grado de acoplamiento entre las _feed_ _lines_ y el resonador. Este debe elegirse de manera que minimice el efecto de carga sobre el resonador sin impedir la transferencia de energía.

En estas condiciones, el acoplamiento entre las líneas de alimentación y el resonador se clasifica como acoplamiento débil (_loose_ _coupling_).

Bajo esta condición de acoplamiento débil, la frecuencia de resonancia puede determinarse mediante la aproximación de línea recta (_straight-line approximation_) propuesta por Troughton en 1969. Esta aproximación establece que la resonancia ocurre cuando el perímetro medio del anillo es igual a un múltiplo entero de la longitud de onda, lo cual se expresa mediante la @ec:resonancia_anillo.


$ 2 pi R_("med") = n dot lambda $<ec:resonancia_anillo>

Donde $R_("med")$ es el radio medio del anillo, $n$ es un número entero correspondiente al modo de resonancia y $lambda$ es la longitud de onda en la línea de transmisión.


Expresando la longitud de onda en función de la permitividad efectiva ($epsilon_("eff")$) dada por la @ec:lambda_eff y sustituyendo dicha expresión en la condición de resonancia (@ec:resonancia_anillo), se obtiene la @ec:eff_ring.

$ epsilon_("eff") = ((n dot c_0) / (f dot 2 pi R_("med") ))^2 $<ec:eff_ring>

Para complementar el analisis de los modos de resonancia del anillo, Wu y Rosenbaum @wu_mode_chart desarrollan un gráfico de los diferentes modos que pueden aparecer, donde relacionan el ancho normalizado del anillo $("W"/R_("med") )$ con la constante de propagación normalizada $(k dot R_("med"))$, donde W es la mitad del ancho del anillo ($2 dot "W" = R_e - R_i$) y k es el numero de onda.

Los modos de resonancia se denominan $T M_("nml")$ donde $T M$ corresponde a transversal magnético (definido anteriormente), n la variación azimutal (alrededor del anillo) la cual indica cuántas longitudes de onda completas se distribuyen a lo largo de la circunferencia del anillo, m es la variación radial y l indica la variación en altura de la onda. Dado que el sustrato es delgado, el campo no varía en altura por lo que habitualmente será $l = 0$.


Luego, partiendo de la condición de resonancia de Troughton (@ec:resonancia_anillo) y expresándola en función del número de onda $(k=2pi/lambda)$ se obtiene la @ec:aproximacion_con_k.

$ k dot R_("med") = n $<ec:aproximacion_con_k>


Esta ecuación indica que la fase acumulada de la onda al dar una vuelta completa al anillo debe ser $2 pi n$. Sin embargo, como advierten Wu y Rosenbaum, esta igualdad es válida para anillos de ancho angosto $("W"/R_("med") -->0)$. En ese caso, el campo viaja en una dirección (la circunferencia) y no hay variación radial, por lo que el modo es puramente $T M_("n10")$. Cuando el ancho del anillo es grande o alcanza aproximadamente la mitad de la longitud de onda a la que fue diseñado, aparecen variaciones del campo en la dirección radial lo que da lugar a modos de alto orden ($m>1$) y efectos de borde que modifican la frecuencia de resonancia; como consecuencia, el valor de $k dot R_("med")$ es menor que n para el modo dado.

Wu y Rosenbaum muestran que el modo $T M_("110")$ es el dominante para cualquier ancho de anillo y establecen que para evitar modos de alto orden se debe cumplir con la @ec:condicion_wu.

$ "W"/R_("med") <= 0.1 $<ec:condicion_wu>



Una de las aplicaciones del resonador de anillo microstrip es la caracterización de propiedades de sustratos. Como se ha visto, la condición de resonancia de Troughton permite determinar la permitividad efectiva mediante la @ec:eff_ring, adicionalmente se puede determinar la tangente de pérdidas a través del factor de calidad. Para ello es necesario cumplir con la @ec:condicion_wu para evitar modos de alto orden.


La obtención de la $tg(delta)$ se basa en el análisis del factor de calidad ($Q$) del modo resonante a partir de las mediciones experimentales del coeficiente de transmisión ($S_(21)$). Utilizando la frecuencia de resonancia ($f$) y el ancho de banda a -3 dB ($Delta f$), se calcula inicialmente el factor de calidad con carga ($Q_L$) mediante la @ec:Q_carga.

$ Q_L = f / (Delta f) $<ec:Q_carga>


Dado que el resonador se encuentra acoplado a las líneas de alimentación a través de los _gaps_, el valor de $Q_L$ incluye el efecto de carga del circuito. Para obtener el factor de calidad descargado ($Q_0$), que representa únicamente las pérdidas internas de la estructura, Chang y Hsieh #cite(<Ring_resonator>, supplement: [p.  139-145]) y Heinola @Heinola_anillos establecen que se debe compensar la pérdida de inserción en la resonancia. Para un anillo acoplado simétricamente, la relación es:

$ Q_0 = Q_L / (1 - 10^(-L/20)) $<ec:Q_sin_carga>

donde $L$ es la pérdida de inserción en [dB] del anillo en la frecuencia de resonancia.

Las pérdidas totales en el resonador, representadas por la inversa del factor de calidad ($1/Q_0$), son la suma de las contribuciones individuales de las pérdidas en el dieléctrico ($1/Q_d$), las pérdidas en el conductor ($1/Q_c$) y las pérdidas por radiación ($1/Q_r$). De acuerdo con Heinola @Heinola_anillos las pérdidas por radiación en un resonador de anillo son despreciables debido a que son estructuras cerradas
($1/Q_r approx 0$), por lo que el factor de calidad dieléctrico puede calcularse con la @ec:q_dielectrico.

$ 1/Q_d = 1/Q_0 - 1/Q_c $<ec:q_dielectrico>

La atenuación por conducción ($alpha_c$) se calcula utilizando el modelo de Pucel et al. [7], que para una línea de microstrip depende de la geometría y de la resistencia superficial del metal. La resistencia superficial $(R_s)$ se define como:
$ alpha_c = R_s/(Z_0 dot W) --> R_s = sqrt((omega dot mu_0)/(2 dot sigma)) $

donde ($omega = 2pi f$) es la frecuencia angular, $(mu_0)$es la permeabilidad del vacío y $(sigma)$ es la conductividad del cobre. Una vez obtenida $(alpha_c)$, el factor de calidad asociado a las pérdidas en el conductor se calcula como:

$ Q_c = (8.686 pi)/(lambda dot alpha_c) $


Finalmente, se obtiene la expresión de la tangente delta ($tg(delta)$) del sustrato utilizada por Heinola @Heinola_anillos.

$ tg(delta) = (epsilon_("eff") dot (epsilon_r -1))/(Q_d dot epsilon_r dot (epsilon_("eff")-1)) $<ec:tan_delta>

Este método permite obtener la $tg(delta)$ completando la caracterización del material.




// ==== Modelo de Parámetros Concentrados

// Para complementar el análisis basado en modelos distribuidos, es necesario introducir un modelo de parámetros concentrados que capture los efectos de acoplamiento no ideales presentes en los gaps. Chang y Hsieh proponen un circuito equivalente riguroso para representar la interacción entre las líneas de alimentación y el anillo resonante.




// #figure(
//   image("imgs/modelo_concentrado_ring_resonator.png", width: 60%),
//   caption: [Circuito de parametros concentrados para un resonador de anillo],
// )<fig:ring_parametros_concentrados>


// Tal como se observa en la @fig:ring_parametros_concentrados, el
// modelo se desglosa en dos secciones:

// + *Lineas de alimentación:* Las líneas de entrada y salida interactúan con el anillo a través de sendas $pi$-redes capacitivas formadas por los elementos $C_1$ y $C_2$. Estas capacitancias parásitas modelan los campos eléctricos acumulados en el *_gap_* del circuito abierto, permitiendo la transferencia de energía al anillo.
// + *Anillo:* El anillo propiamente dicho se representa mediante la red central en forma de rombo compuesta por las impedancias equivalentes $Z_a$ y $Z_b$. Físicamente, cuando la señal ingresa al anillo, se divide propagándose por dos caminos paralelos (las dos mitades de la circunferencia). Estas impedancias modelan el comportamiento de dichos trayectos, teniendo en cuenta la longitud eléctrica y el retraso de fase de la señal. Cuando las ondas que viajan por ambos caminos se recombinan en fase a la salida, el modelo reproduce matemáticamente el fenómeno de resonancia.

// Este modelo circuital resulta crucial para la caracterización precisa del sustrato FR4. Las capacitancias parásitas del gap introducen una carga reactiva sobre el anillo que provoca un ligero desplazamiento de la frecuencia de resonancia medida ($f$) con respecto a la frecuencia de resonancia ideal calculada teóricamente.

// Para que las ecuaciones simplificadas vistas anteriormente (@ec:eff_ring y @ec:tan_delta) sean válidas sin necesidad de  cálculos complejos basados en este modelo, se debe asegurar operativamente un régimen de acoplamiento muy débil. Físicamente, esto implica diseñar gaps lo suficientemente grandes para minimizar la magnitud de $C_2$, pero lo sufucientemente chico como para poder acoplar la señal.

=== Acoplador Direccional


Los acopladores direccionales son dispositivos pasivos de microondas utilizados para dividir o combinar potencia en redes de radiofrecuencia, permitiendo controlar la energía entre distintos puertos.

Un acoplador direccional se modela como una red de cuatro puertos. Cuando una señal se aplica en uno de los puertos, la mayor parte de la potencia se transmite hacia el puerto de salida principal, mientras que una fracción de la señal es acoplada hacia el puerto acoplado. El último puerto se denomina puerto aislado, ya que idealmente no recibe potencia cuando la señal se propaga en la dirección prevista.


#todo("en este parrafo hay chamuyo con la parte de sistemas de RF, no versear")
En @acoplador_minicircuit se describe que la característica de un acoplador direccional es su capacidad para acoplar potencia de forma dependiente de la dirección de propagación de la onda en la línea de transmisión. De esta manera, el dispositivo puede distinguir entre ondas que se desplazan en direcciones opuestas, lo que resulta particularmente útil para medir potencia directa y reflejada en sistemas de RF.



==== Parámetros característicos

Para determinar el comportamiento de un acoplador direccional y evaluar su desempeño en aplicaciones prácticas, Fano #cite(<acoplador_direccional_parametros>, supplement: [p.  25]) nombra los siguientes parámetros característicos.

- *Factor de acoplamiento ($C$):* Indica la relación entre la potencia aplicada al puerto de entrada y la potencia que aparece en el puerto acoplado. Se define como:
  $ C = -10 log_10(P_3 / P_1) #text("[dB]") $

- *Aislamiento ($I$):* Describe la cantidad de potencia que aparece en el puerto aislado cuando se aplica una señal en el puerto de entrada. En un acoplador ideal, el aislamiento sería infinito, aunque en dispositivos reales presenta un valor finito.
  $ I = -10 log_10(P_4 / P_1) #text("[dB]") $

- *Directividad ($D$):* Mide la capacidad del acoplador para separar las ondas que se propagan en direcciones opuestas dentro de la línea de transmisión. Este parámetro se define como la diferencia entre el aislamiento y el acoplamiento. Dado que la directividad no suele medirse de forma explícita o directa, se calcula mediante la relación:
  $ D = I - C #text("[dB]") $
  Una directividad elevada indica que el acoplador puede distinguir de forma efectiva entre la potencia incidente y la potencia reflejada.

- *Pérdida de inserción ($L$):* Corresponde a la reducción de potencia que experimenta la señal al atravesar el acoplador por la línea principal. En un dispositivo ideal esta pérdida sería nula, aunque en la práctica siempre existe una pequeña atenuación debido a las pérdidas en los materiales dieléctricos y en los conductores de la estructura.
  $ L = -10 log_10(P_2 / P_1) #text("[dB]") $


==== Acoplador direccional de líneas acopladas

Una de las implementaciones más comunes y utilizadas en circuitos de microondas es el acoplador direccional de líneas acopladas. Consiste en dos líneas de transmisión dispuestas en paralelo a una distancia pequeña entre sí. Esta configuración permite que los campos electromagnéticos asociados a la propagación de la señal en la línea principal interactúen con la línea adyacente, produciendo una transferencia controlada de potencia, pero manteniendo una separación adecuada para no afectar significativamente la propagación original.

Estos acopladores se implementan frecuentemente en tecnología _microstrip_, donde las líneas de transmisión se fabrican mediante pistas conductoras sobre un sustrato dieléctrico. Debido a su simplicidad de fabricación, son ampliamente utilizados en sistemas de RF para el monitoreo de potencia, la medición de ondas reflejadas y aplicaciones de instrumentación.

#v(-0.5cm)
#subpar.grid(
  figure(image("imgs/ilustrations/acoplador_direccional_microstrip.png"), caption: [Acoplador direccional microstrip]),
  <fig:acoplador_direccional_microstrip>,

  figure(image("imgs/ilustrations/acoplador_direccional_stripline.png"), caption: [Acoplador direccional stripline]),
  <fig:acoplador_direccional_stripline>,

  columns: (1fr, 1fr),
  gap: 0.5cm,
  gutter: -0cm,
  caption: [Acopladores direccionales _microstrip_ y _stripline_],
)
Pozar #cite(<Pozar>, supplement: [p.])  describe que, físicamente un acoplador direccional de este tipo posee cuatro puertos bien definidos:
- *Puerto 1:* Puerto de entrada (_input port_)
- *Puerto 2:* Puerto de salida principal (_through port_)
- *Puerto 3:* Puerto acoplado (_coupled port_)
- *Puerto 4:* Puerto aislado (_isolated port_)

// Cuando una señal se aplica al puerto de entrada, la mayor parte de la potencia se transmite hacia el puerto de salida principal, mientras que una pequeña fracción es transferida a la línea acoplada (puerto 3). Idealmente, el puerto aislado no recibe señal debido a la cancelación de fase producida por la direccionalidad del dispositivo.

El nivel de acoplamiento depende directamente de la geometría de la estructura. Una menor distancia de separación entre las pistas (_gap_) produce un mayor acoplamiento electromagnético, mientras que una separación más amplia reduce la cantidad de potencia transferida.



==== Análisis de modos y longitud del acoplador

El comportamiento de estas estructuras, según Pozar #cite(<Pozar>, supplement: [p.]), se describe mediante la superposición de dos modos de propagación fundamentales: el modo par (_even mode_) y el modo impar (_odd mode_).

En el *modo par*, las tensiones en ambas líneas son iguales y están en fase, por lo que las corrientes fluyen en la misma dirección. Como consecuencia, el plano de simetría entre las líneas se comporta como un muro magnético perfecto (PMC), donde el campo magnético tangencial es nulo. Este modo está regido por la impedancia característica par $Z_(0 e)$.

Por el contrario, en el *modo impar*, las tensiones son iguales en magnitud pero desfasadas $180 degree$, por lo que las corrientes circulan en direcciones opuestas. En este caso el plano de simetría actúa como un muro eléctrico perfecto (PEC), donde el campo eléctrico tangencial es nulo. Este modo tiene una impedancia característica denominada impedancia impar $Z_(0 o)$.



#figure(
  image("imgs/placeholder.jpg", width: 30%),
  caption: [Distribución de campos para el modo par e impar en líneas acopladas.],
)<fig:modos_par_impar>

Debido a que las condiciones de frontera para cada modo son distintas, las señales par e impar experimentan diferentes distribuciones de campo y acumulan fases distintas a lo largo de la región acoplada.

Para que el dispositivo presente el comportamiento deseado, las contribuciones de ambos modos deben interferir de forma destructiva en el puerto aislado y constructiva en el puerto acoplado. Pozar #cite(<Pozar>, supplement: [p.]) indica que esta condición de interferencia  es óptima cuando la longitud física de la región donde las líneas permanecen paralelas es exactamente igual a un cuarto de la longitud de onda a la frecuencia de diseño.

Bajo esta premisa, las señales provenientes de los modos par e impar se combinan de tal forma que se logra la direccionalidad del componente. Por lo tanto, la longitud física ($L$) de la región de acoplamiento se define mediante la ecuación (@ec:longitud_acoplador).

$ L = lambda / 4 $<ec:longitud_acoplador>


==== Relación entre impedancias y acoplamiento

El factor de acoplamiento del dispositivo está determinado por las impedancias de los modos par e impar. Para un acoplador ideal simétrico, estas impedancias deben cumplir según Pozar #cite(<Pozar>, supplement: [p. 353]):

$ Z_(0 e) dot Z_(0 o) = Z_0^2 $

Donde $Z_0$ es la impedancia característica de la linea de transmisión, tipicamente $50 Omega$. Además, el factor de acoplamiento puede expresarse en términos de estas impedancias como:

$ C = 20 dot log(k) --> C =20 dot log ((Z_(0 e) + Z_(0 o))/ (Z_(0 e) - Z_(0 o))) $<ec:fact_c>

lo cual permite determinar el diseño geométrico necesario para lograr un determinado valor de acoplamiento.


Pozar #cite(<Pozar>, supplement: [p.  351-356]) también define que el coeficiente de acoplamiento ($k$) es la relación de tensión entre el puerto acoplado y el puerto de entrada, siendo $V_3$ la tensión del puerto 3 y $V_1$ la tensión del puerto de entrada.

$ k = V_3/V_1 --> k = (Z_(0 e) + Z_(0 o))/ (Z_(0 e) - Z_(0 o)) $<ec:coef_c>



Las impedancias de los modos par e impar se calculan con  la @ec:impedancia_par y la @ec:impedancia_impar, donde k es el coeficiente de acoplamiento (acotado entre 0 y 1) y no debe confundirse con el factor de acoplamiento C expresado en [dB].


#grid(
  columns: (1fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$ Z_(0 e) = Z_0 dot sqrt((1+k)/(1-k)) $<ec:impedancia_par>],
  [$ Z_(0 o) =Z_0 dot sqrt((1-k)/(1+k)) $<ec:impedancia_impar>],
)






==== Acoplador híbrido de cuadratura o branch line
Además del acoplador de líneas acopladas, existen otros tipos de acopladores como el acoplador de cuadratura, el cual Pozar #cite(<Pozar>, supplement: [p.  343-347]) señala que es un dispositivo de cuatro puertos que divide la potencia de entrada en dos salidas de igual amplitud, pero con una diferencia de fase de $90 degree$ entre ellas. Como se observa en la @fig:acoplador_cuadratura, este dispositivo se implementa mediante líneas de transmisión en forma de cuadrado, donde cada una de las líneas tiene una longitud física equivalente a $lambda/4$  calculada a la frecuencia de diseño.


#figure(
  image("imgs/ilustrations/acoplador_hibrido_dibujo.png", width: 60%),
  caption: [Acoplador en cuadratura],
)<fig:acoplador_cuadratura>

Su funcionamiento según Pozar #cite(<Pozar>, supplement: [p.]) se basa en aplicar una señal al puerto de entrada (puerto 1 o _input_), la cual se divide equitativamente entre los puertos 2 (_output_) y 3 (_coupled_), cada uno recibiendo la mitad de la potencia de entrada (#qty[3][dB]), mientras que el puerto 4 (_isolated_) permanece idealmente aislado.


Las impedancias características de las líneas que conforman el acoplador se eligen para lograr el acoplamiento deseado. Para un acoplador de impedancia $Z_0$ (típicamente $50 Omega$), las ramas horizontales (en serie) deben tener una impedancia de $Z_0 / sqrt(2)$, mientras que las ramas verticales (en derivación) deben tener una impedancia de $Z_0$. Esta elección de impedancias es la que garantiza el comportamiento en cuadratura y el aislamiento del puerto 4.

Cabe destacar que este tipo de acoplador no se utilizará en el diseño práctico de este trabajo, pero su mención permite contextualizar otras alternativas dentro de la familia de acopladores direccionales.




// #todo("llevar la parte del analizador de espectro como anexo")
// === Analizador de espectro


// El analizador de espectro es un instrumento de medición utilizado para analizar señales en el dominio de la frecuencia. A diferencia de instrumentos como el osciloscopio, que muestran la amplitud de una señal en función del tiempo, el analizador de espectro representa la potencia de la señal en función de la frecuencia, permitiendo observar las distintas componentes espectrales que la conforman.

// #figure(
//   image("imgs/analizador_medición.jpg", width: 30%, height: 5.5cm, fit: "stretch"),
//   caption: [Medición en el analizador de espectro],
// )

// En la pantalla del instrumento, el eje horizontal corresponde a la frecuencia, mientras que el eje vertical representa la amplitud o potencia de la señal, generalmente expresada en unidades logarítmicas como dBm.



// #figure(
//   image("imgs/analizador_spectro.png", width: 50%),
//   caption: [Diagrama en bloques de un analizador de espectro],
// )<fig:analizador_espectro>



// De acuerdo con el documento Spectrum Analyzer Basics #todo("Poner referencia"), en este tipo de instrumento, la señal de entrada se mezcla con la señal generada por un oscilador local (LO) cuyo valor de frecuencia se barre a lo largo del rango que se desea analizar. Como resultado del proceso de mezcla se generan componentes de frecuencia suma y diferencia, de las cuales se selecciona una mediante un filtro de frecuencia intermedia (IF).

// A medida que el oscilador local barre el rango de frecuencias seleccionado, el analizador mide la potencia de las componentes que pasan por el filtro IF. Esta información se procesa y se representa en la pantalla del instrumento, reconstruyendo de esta forma el espectro de la señal de entrada.

// Los analizadores de espectro son ampliamente utilizados en el análisis de sistemas de radiofrecuencia y microondas, ya que permiten medir el nivel de potencia de señales RF, detectar armónicos o señales espurias y evaluar el comportamiento espectral de transmisores y dispositivos electrónicos.

// Como se puede observar, el analizador de espectro es un instrumento utilizado principalmente para medir y visualizar el contenido espectral de una señal, es decir, su potencia en función de la frecuencia. A diferencia de un analizador vectorial de redes, no está diseñado para inyectar una señal en un puerto y medir la respuesta en otro puerto del dispositivo bajo prueba.

// Sin embargo, algunos analizadores de espectro incorporan una función denominada Tracking Generator (TG), que permite generar una señal cuya frecuencia sigue el barrido del analizador. De esta manera, es posible inyectar una señal en el dispositivo bajo prueba y medir su respuesta en frecuencia utilizando el propio analizador, lo que permite realizar mediciones básicas de transmisión en dispositivos como filtros, amplificadores o líneas de transmisión, en nuestro caso particular utilizaremos dicha función para caracterizar los paraemtros fundamentales de un acoplador direccional (_Coupling_, _Isolation_, _Pérdida de transmisión directa e inversa_).

= Caracterización del sustrato

La caracterización del sustrato FR4 se realizará a través de tres métodos de medición independientes: diferencia de fase en stubs _microstrip_, resonadores de anillo y capacitor de placas planas paralelas.



// En cuanto al análisis de pérdidas, se adopta el modelo de Schneider para la atenuación dieléctrica, mientras que las pérdidas por conducción se estiman a partir del modelo de Pucel et al.. Las pérdidas por radiación se consideran despreciables en el rango de frecuencias y configuraciones geométricas consideradas, de acuerdo con el criterio establecido por Belohoubek y Denlinger para estructuras de microcinta cerradas.

== Método 1: diferencia de fase en stubs microstrip
El primer método consiste en la utilización de stubs de microstrip con terminación a circuito abierto de diferentes longitudes, fabricados sobre el sustrato FR4, con el objetivo de estimar la permitividad efectiva ($epsilon_("eff")$) del sustrato. Este método se basa en la relación entre la frecuencia de resonancia y antiresonancia de un stub y su longitud eléctrica, la cual depende de forma directa del parámetro $epsilon_("eff")$.

Si se intentara medir las resonancias y antiresonancias haciendo uso de un solo stub abierto incurririamos en errores de medición como la capacitancia de borde en el extremo abierto y la longitud eléctrica añadida por la transición entre el conector SMA con la línea _microstrip_ y el cable del VNA lo que provocaría, aunque en este caso intuimos despreciable, sería un desplazamiento al fin de las frecuencias de resonancias medidas.

Para mitigar estos errores, se utiliza un par de stubs geométricamente idénticos excepto en su longitud, con una diferencia $Delta_L$ que al reordenar la @ec:longitud_stub se consiguen la @ec:stub_1_L y @ec:stub_2_DL.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$ f_("stub1") = n dot c_0 / (4 dot L dot sqrt(epsilon_("eff"))) $<ec:stub_1_L>],
  [$ f_("stub2") = n dot c_0 / (4 dot (L + Delta_L) dot sqrt(epsilon_("eff"))) $<ec:stub_2_DL>],
)

Al ser los stubs muy similares, los efectos parásitos son prácticamente los mismos en ambos, por lo que al restar la @ec:stub_1_L con la @ec:stub_2_DL mediante diferencias en sus frecuencias de resonancia el error sistemático se cancela.

El método consiste en medir el parámetro $S_11$ de cada stub y analizar la fase para identificar las frecuencias de resonancia y antiresonancia.  Al obtenerlas, considerando el mismo orden armónico en cualquiero par de stubs se despeja la permitividad efectiva en la @ec:delta_pair_e_eff.

$
  epsilon_"eff" = [(c_0 dot n)/(4 dot Delta_L) dot (1/f_("stub2") - 1/f_("stub1"))]^2
$<ec:delta_pair_e_eff>

Esta ecuación depende únicamente de ΔL y no de la longitud absoluta de los stubs, por lo que la exactitud del método está ligada fuertemente a la medición de las longitudes individuales como así también al proceso de fabricación que puede alterar la geometría del stub. Promediando las estimaciones de los diferentes pares de stubs para diferentes armónicos permite reducir la incertidumbre, obteniendo un valor representativo de $epsilon_"eff"$.

=== Simulación y diseño
El diseño de los stubs se realizó utilizando la calculadora de líneas microstrip integrada en Qucs (@fig:qucs_stubs_calculadora). Para una impedancia característica de 50 $Omega$, se calcularon las dimensiones geométricas (ancho W y longitud L) de cada stub empleando el modelo de Hammerstad y Jensen en su formulación cuasi-estática. Este modelo proporciona la permitividad efectiva y la impedancia característica en función de la geometría y las propiedades del sustrato.

Sobre el PCB de sustrato FR4 se diseñaron cinco stubs con distintas longitudes eléctricas, correspondientes a fracciones de la longitud de onda de la frecuencia central de 915 MHz: $lambda$/2, $lambda$/4 y $lambda$/8.

#subpar.grid(
  figure(
    image("imgs/stub_calculadora.png", width: 100%),
    caption: [Ejemplo de diseño para stub L=$lambda$/8 (Qucs)],
  ),
  <fig:qucs_stubs_calculadora>,

  figure(
    image("imgs/feko/feko_stubs.png", width: 100%),
    caption: [Modelo 3D de simulación de los stubs (Altair Feko)],
  ),
  <fig:feko_stubs_general>,

  columns: (1fr, 1.22fr),
  gap: 0.5cm,
  caption: [Campo cercano para los armónicos del stub L = \lambda/2],
  label: <fig:campo_cercanjo_stubs>,
)
Adicionalmente, se incluyeron dos stubs con longitudes de 50 mm y 100 mm, con el fin de generar resonancias en frecuencias diferentes y así disponer de un conjunto de datos más amplio y redundante para el cálculo, y así conformar finalmente un sistema de 5 puertos cuya matriz S será de la forma de @ec:matriz_s_stubs donde $S_11$ reperesenta el stub de $lambda/2$, $S_22$ el de $lambda/4$, $S_33$ el de $lambda/8$, $S_44$ el de 50mm y $S_55$ el de 100mm.
$
  S = mat(
    S_(1 1), S_(1 2), S_(1 3), S_(1 4), S_(1 5);
    S_(2 1), S_(2 2), S_(2 3), S_(2 4), S_(2 5);
    S_(3 1), S_(3 2), S_(3 3), S_(3 4), S_(3 5);
    S_(4 1), S_(4 2), S_(4 3), S_(4 4), S_(4 5);
    S_(5 1), S_(5 2), S_(5 3), S_(5 4), S_(5 5);
  )
$<ec:matriz_s_stubs>


Con las dimensiones obtenidas, se construyó un modelo tridimensional de cada stub sobre el sustrato FR4 en el software de simulación Altair Feko. La @fig:feko_stubs_general muestra la disposición de los stubs en el modelo de simulación. Para cada stub se realizó una simulación en dominio de la frecuencia, excitando de a un puerto a la vez y obteniendo el parámetro $S_11$ ($Gamma$) en el rango de 100 MHz a 6 GHz correspondiente al mismo rango que se estableció en la medición física mediante el VNA N9923A FieldFox.

A partir de los resultados de simulación se generaron gráficos de magnitud y fase de $S_11$ para todos los stubs, tanto en simulación como posteriormente en medición, con el fin de comparar el comportamiento resonante, particularmente en la fase
#figure(
  image("imgs/feko/feko_stubs_mag_comparativa.png", width: 100%),
  caption: [Magnitud [dB] del parametro $S_11$,$S_22$,$S_33$,$S_44$,$S_55$],
)<fig:stubs_feko_mag>
#figure(
  image("imgs/feko/feko_stubs_phase_wrapped_comparativa.png", width: 100%),
  caption: [Fase [°] envuelta del parametro $S_11$,$S_22$,$S_33$,$S_44$,$S_55$],
)<fig:stubs_feko_fase_wrap>
#figure(
  image("imgs/feko/feko_stubs_phase_unwrapped_comparativa.png", width: 100%),
  caption: [Fase [°] desenvuelta del parametro $S_11$,$S_22$,$S_33$,$S_44$,$S_55$],
)<fig:stubs_feko_fase_unwrap>

En la @fig:stubs_feko_mag se presenta un gráfico de la magnitud en decibeles de los parámetros $S_11$,$S_22$,$S_33$,$S_44$,$S_55$ donde se identifican los picos de reflexión, correspondientes a las frecuencias donde el stub presenta una impedancia de entrada mínima, es decir, se encuentra en resonancia. Sin embargo, para la realización de este método de caracterización, el gráfico de fase de la @fig:stubs_feko_fase_wrap nos aporta más información, ya que nos permite identificar tanto las resonancias como las antiresonancias a partir de los cruces por cero que se observan en su forma envuelta.

Posteriormente notaremos que el uso de la fase envuelta puede conducirnos a ciertos errores en la detección de falsos positivos de puntos de resonancia, por lo que el procesamiento de los datos lo realizaremos mediante la fase desenvuelta. Esta última elimina las discontinuidades artificiales y facilita la identificación de los múltiplos de 180°, como se observa en la @fig:stubs_feko_fase_unwrap.

Además, a modo cualitativo y con un objetivo didactico, se obtuvo la distribución de campo cercano en el plano del sustrato para cada excitación individual, lo que permite representar la densidad del campo en las proximidades de cada stub permitiendo ver la onda estacionaria para los diferentes armónicos en la @fig:campo_cercano_stubs. Se identifica el respectivo armónico mediante la condicion $N°_("armónico") = 2 dot N°_"max" - 1$

#subpar.grid(
  figure(image("imgs/feko/stubs_campo/st_arm1.png", width: 100%), caption: [Armónico 1 $approx$ 0.418GHz]),
  figure(image("imgs/feko/stubs_campo/st_arm2.png", width: 100%), caption: [Armónico 2 $approx$ 1.98GHz]),
  figure(image("imgs/feko/stubs_campo/st_arm3.png", width: 100%), caption: [Armónico 3 $approx$ 2.82GHz]),

  figure(image("imgs/feko/stubs_campo/st_arm4.png", width: 100%), caption: [Armónico 4 $approx$ 3.66GHz]),
  figure(image("imgs/feko/stubs_campo/st_arm5.png", width: 100%), caption: [Armónico 5 $approx$ 4.5GHz]),
  figure(image("imgs/feko/stubs_campo/st_arm6.png", width: 100%), caption: [Armónico 6 $approx$ 5.27GHz]),

  columns: (1fr, 1fr, 1fr),
  caption: [Campo cercano para los armónicos del stub L=$lambda$/2],
  gap: 0.5cm,
  label: <fig:campo_cercano_stubs>,
)


=== Implementación
Tras la etapa de simulación, se procedió a la fabricación del PCB que contiene los cinco stubs diseñados. El proceso incluyó la transferencia del diseño realizado en KiCAD mediante fotolitografía sobre el cobre y posteriormente se realizó el grabado por cloruro férrico. En la @fig:pcb_stubs se muestran imágenes del proceso de fabricación, desde la transferencia del negativo en un ambiente con luz roja hasta el resultado final antes de soldarle los conectores SMA.

#subpar.grid(
  figure(
    image("imgs/ilustrations/pcb/stubs_pcb_pre.png", width: 65%, height: 5cm, fit: "stretch"),
    caption: [PCB durante proceso fotolitografico],
  ),
  // figure(image("imgs/anillos_stubs_filmina_fr4.png",height: 3.5cm)),
  figure(
    image("imgs/ilustrations/pcb/stubs_pcb.png", width: 65%, height: 5cm, fit: "stretch"),
    caption: [Resultado final ],
  ),

  columns: (1fr, 1fr),
  caption: [Fabricación del PCB de stubs],
  gap: 0.5cm,
  label: <fig:pcb_stubs>,
)



=== Mediciones

Una vez fabricados los stubs, las mediciones se llevan a cabo mediante un analizador vectorial de redes (VNA). En particular, se mide el parámetro $S_(11)$, correspondiente al coeficiente de reflexión en el puerto de entrada.

Para la conexión de los stubs al VNA, se soldaron conectores SMA hembra en el extremo de la línea de alimentación de cada stub. Se tuvo especial cuidado con los residuos de la soldadura para evitar la formación capacitancias no deseadas que puedan introducir efectos parásitos en el resultado de medición.

Antes de realizar las mediciones, se llevó a cabo un procedimiento de calibración del VNA utilizando un kit de calibración tipo SOLT (Short-Open-Load-Through). La calibración se realizó en el plano de los conectores SMA, es decir, en el extremo del cable coaxial que se conecta al stub, para eliminar los efectos de fase y atenuación introducidos por el cable y los adaptadores. Luego el VNA fue configurado con un ancho de banda de IF (Intermediate Frequency) de #qty[300][Hz] para reducir el ruido de medición y mejorar la relación señal-ruido, y se aplicó un promedio de 5 barridos

Finalmente se realizaron las mediciones desde #qty[100][MHz] hasta #qty[6][GHz] con 1001 puntos por lo que la medición se realizó a pasos
de #qty[5.89][MHz].

#figure(
  image("imgs/stub_un_cuarto_medicion.png", width: 50%),
  caption: [Medición del stub de $lambda$/4],
)<fig:stub_un_cuarto>

Durante la medición, cada stub fue excitado individualmente mientras los demás stubs permanecían sin conectar (en circuito abierto). Esta configuración podría introducir cierto acoplamiento entre stubs debido a la proximidad física entre ellos. Sin embargo, durante el diseño se tuvo en cuenta esta posibilidad y se adoptó como criterio de diseño que la separación mínima entre stubs debería ser $d>=3dot w$ con w es el ancho de la línea _microstrip_. Dado que fue diseñado para una impedancia caracteristica $Z_0 = 50 Omega$, w es #qty[2.97][mm]  del stub dando como resultado $d>=8.92$ mm.

Para evaluar cuantitativamente este efecto, se analizaron los parámetros por fuera de la diagonal principal de la matriz de la @ec:matriz_s_stubs obtenidos de las simulaciones en Feko, los cuales representan la transmisión desde el stub excitado (agresor) hacia cada uno de los demás stubs (víctimas). Siendo una red pasiva y siendo excitados con el mismo nivel de señal, por simetría los parametros $S_("ij")$ y $S_("ji")$ deberían ser iguales.

En la @fig:acoplamiento_stubs se presentan los parámetros de acoplamiento para cada una de las diferentes excitaciones del stub agresor con las restantes 4 líneas victimas.

#subpar.grid(
  grid.cell(colspan: 2, figure(
    image("imgs/feko/stubs_acop/acop_100mm.png", width: 100%, height: 5cm, fit: "stretch"),
    caption: [Agresor: Stub 100mm],
  )),
  grid.cell(colspan: 2, figure(
    image("imgs/feko/stubs_acop/acop_50mm.png", width: 100%, height: 5cm, fit: "stretch"),
    caption: [Agresor: Stub 50mm],
  )),
  grid.cell(colspan: 2, figure(
    image("imgs/feko/stubs_acop/acop_lambda_8.png", width: 100%, height: 5cm, fit: "stretch"),
    caption: [Agresor: Stub $lambda$/8],
  )),
  grid.cell(colspan: 1, []),
  grid.cell(colspan: 2, figure(
    image("imgs/feko/stubs_acop/acop_lambda_4.png", width: 100%, height: 5cm, fit: "stretch"),
    caption: [Agresor: Stub $lambda$/4],
  )),
  grid.cell(colspan: 2, figure(
    image("imgs/feko/stubs_acop/acop_lambda_2.png", width: 100%, height: 5cm, fit: "stretch"),
    caption: [Agresor: Stub $lambda$/2],
  )),
  columns: (1fr,) * 6,
  caption: [Magnitud de los parámetros de acoplamiento para cada stub excitado],
  gap: 0.5cm,
  label: <fig:acoplamiento_stubs>,
)

Los resultados muestran que el acoplamiento máximo promedio observado fue menor a -20 dB en todo el rango de frecuencias, con la mayoría de los pares presentando valores inferiores a -30 dB. Adicionalmente, se verificó que el acoplamiento en las frecuencias donde los stubs presentan resonancias armónicas entre sí, pero incluso en esos puntos el valor se mantiene por debajo -20 dB.

Por lo tanto, se concluye que el acoplamiento mutuo entre stubs es despreciable para todo el rango de frecuencias utilizado, validando así el banco de medición utilizado y asegurando que las mediciones de $S_11$, $S_22$, $S_33$, $S_44$, $S_55$ reflejan el comportamiento individual de cada stub.

=== Procesamiento de datos

A partir de las mediciones de fase obtenidas para cada stub, se analizan los datos utilizando un script desarrollado en Python en el cual, en virtud de las condiciones planteadas en la @ec:resonancia_open_stub, se buscan las frecuencias donde la fase presenta cruces por los múltiplos de 180°. Si bien esta idea sería válida si la señal no tuviera ruido de fase, en la práctica no podemos dar por sentado eso.

El VNA entrega los parámetros de dispersión con la fase envuelta (_wrapped_), es decir, acotada al intervalo de -180° a 180°, por lo que esta puede presentar saltos abruptos artificiales cada vez que la fase acumulada supera los extremos del intervalo. Cabe destacar que estos saltos no son parte del fenómeno de resonancia, sino una ambigüedad matemática producto de la función arcotangente. Por este motivo, la fase envuelta es susceptible al ruido de fase o a espurios presentes en la señal, que podrían provocar un salto de fase que sería interpretado como un falso positivo de resonancia.

#subpar.grid(
  figure(
    image("imgs/stubs/medicion_fase_envuelta_stubs.jpg", width: 100%, height: 6cm, fit: "stretch"),
    caption: [Fase envuelta],
  ), <fig:fase_envuelta_stubs>,
  figure(
    image("imgs/stubs/medicion_fase_desenvuelta_stubs.jpg", width: 100%, height: 6cm, fit: "stretch"),
    caption: [Fase desenvuelta],
  ),
  columns: 1fr,
  caption: [Medición de fase de los stubs],
  gap: 0.5cm,
  label: <fig:medicion_fase_stubs>,
)
Este fenómeno fue observado luego de procesar los datos de fase presentados en la @fig:fase_envuelta_stubs, donde al desenvolver la fase se detectó que, de haber sido analizado con la fase envuelta, se habría incurrido en un error al interpretar falsas resonancias.

#todo("Aca poner el caso donde se vio que por fase envuelta aparecia una resonancia que en desenvuelta no")

Para evitar este problema, el script primero desenrolla la fase (_unwrapping_) de cada curva recorriendo los sucesivos puntos de frecuencia de las curvas presentadas en la @fig:fase_envuelta_stubs de tal forma que al detectar una diferencia de fase entre dos muestras consecutivas que supera los 180° en valor absoluto, se suman o restan 360° a todos los puntos posteriores. De esta manera se eliminan los saltos artificiales y se recupera la evolución continua de la fase con la frecuencia. Luego, con la fase desenvuelta, se analizan las sucesivas resonancias y antiresonancias al recorrer las curvas y acumulando 180° de fase entre cada uno de los puntos de interés; esto nos permite obtener las frecuencias de los armónicos donde ocurren resonancias y antiresonancias en cada stub.

Con los datos de frecuencias de resonancia obtenidos




Como se ilustra en la #todo("IMAGEN") las frecuencias de resonancia son aproximadamente multiplos impares debido a que se trata de stubs con terminación a circuito abierto.

Al obtener todas las frecuencias de resonancia de cada stub, se analizan de a pares y se otiene el epsilon efectivo promedio
utilizando la #todo("ecuacion"), teniendo en cuenta que se deben utilizar los armónicos de igual valor, es decir, el primer armónico de un stub con el primer armónico del otro stub.

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


== Ánalisis de resultados




= Diseño del acoplador direccional

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
  figure(image("imgs/coupled_insoladora.jpg", fit: "stretch", height: 4cm, width: 70%)),
  figure(image("imgs/acopladores_diseñados.jpg", fit: "stretch", height: 4cm, width: 70%)),

  columns: (1fr, 1fr),
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
  port_name: "output",
  dir_coupler_name: "ACD1",
  mag: "imgs/ACD1/adc1_through_mag_s11_s21.png",
  pha: "imgs/ACD1/adc1_through_phase_s11_s21.png",
  smith: "imgs/ACD1/adc1_through_smith_s11.png",
  dut: "imgs/ACD1/adc1_through_bench.jpg",
  offset_dut_pt: 30pt,
)


#figures_matrix(
  description: "Medición del puerto acoplado",
  port_name: "acoplado",
  dir_coupler_name: "ACD1",
  mag: "imgs/ACD1/adc1_coupled_mag_s11_s21.png",
  pha: "imgs/ACD1/adc1_coupled_phase_s11_s21.png",
  smith: "imgs/ACD1/adc1_coupled_smith_s11.png",
  dut: "imgs/ACD1/adc1_coupled_bench.png",
  offset_dut_pt: 0pt,
)


#figures_matrix(
  description: "Medición del puerto aislado",
  port_name: "aislado",
  dir_coupler_name: "ACD1",
  mag: "imgs/ACD1/adc1_isolated_mag_s11_s21.png",
  pha: "imgs/ACD1/adc1_isolated_phase_s11_s21.png",
  smith: "imgs/ACD1/adc1_isolated_smith_s11.png",
  dut: "imgs/ACD1/adc1_isolated_bench.jpg",
  offset_dut_pt: 26pt,
)


#pagebreak()
#todo("Modificar la foto del nuevo aislado")

Midiendo el acoplador de manera inversa, es decir, el puerto 1 ahora es el puerto 2:

#figures_matrix(
  description: "Medición del puerto acoplado y del puerto aislado con el DUT invertido",
  port_name: "acoplado",
  dir_coupler_name: "ACD1_inverted",
  mag: "imgs/ACD1/adc1_isolatedInverted(new-coupled)_mag_s11_s21.png",
  smith: "imgs/ACD1/adc1_isolated_inverted_bench.jpg",
  pha: "imgs/ACD1/adc1_coupledInverted(new-Isolated)_mag_s11_s21.png",
  dut: "imgs/ACD1/adc1_coupled_inverted_bench.jpg",
  cap_smith_opt: "Setup para medición del puerto acoplado del DUT",
  cap_dut_opt: "Setup para medición del puerto aislado del DUT",
  cap_pha_opt: "Magnitud (dB) del parámetro de reflexión y transmisión del puerto aislado",
  cap_mag_opt: "Magnitud (dB) del parámetro de reflexión y transmisión del puerto acoplado",
  offset_dut_pt: -10pt,
  offset_smith_pt: -14pt,
)

#pagebreak()





El segundo acoplador direccional microstrip el cual fue simulado y diseñado con cinta de cobre para prototipar obtenemos las siguientes mediciones.


#figures_matrix(
  description: "Medición del puerto de salida",
  port_name: "output",
  dir_coupler_name: "ACD2",
  mag: "imgs/ACD2/adc2_through_mag_s11_s21.png",
  pha: "imgs/ACD2/adc2_through_phase_s11_s21.png",
  smith: "imgs/ACD2/adc2_through_smith_s11.png",
  dut: "imgs/ACD2/adc2_through_bench.jpg",
  offset_dut_pt: 42pt,
)


// mag:"https://www.researchgate.net/profile/Erick-Reyes-Vera/publication/308926650/figure/fig1/AS:414578841276416@1475854706479/Figura-2-Anillos-resonadores-elemento-propuesto-por-J-Pendry-La-disposicion-de-las_Q320.jpg",

#figures_matrix(
  description: "Medición del puerto acoplado",
  port_name: "acoplado",
  dir_coupler_name: "ACD2",
  mag: "imgs/ACD2/adc2_coupled_mag_s11_s21.png",
  pha: "imgs/ACD2/adc2_coupled_phase_s11_s21.png",
  smith: "imgs/ACD2/adc2_coupled_smith_s11.png",
  dut: "imgs/ACD2/adc2_coupled_bench.jpg",
  offset_dut_pt: 26pt,
)

#figures_matrix(
  description: "Medición del puerto aislado",
  port_name: "aislado",
  dir_coupler_name: "ACD2",
  mag: "imgs/ACD2/adc2_isolated_mag_s11_s21.png",
  pha: "imgs/ACD2/adc2_isolated_phase_s11_s21.png",
  smith: "imgs/ACD2/adc2_isolated_smith_s11.png",
  dut: "imgs/ACD2/adc2_isolated_bench.jpg",
  offset_dut_pt: 43pt,
)


#pagebreak()

El tercer acoplador direccional se diseño en formato stripline, luego de haber sido simulado se implemntó con cinta de cobre sobre un PCB de una capa de FR4 permitiendonos obtener las siguientes mediciones.


#figures_matrix(
  description: "Medición del puerto de salida",
  port_name: "output",
  dir_coupler_name: "ACD3",
  mag: "imgs/ACD3/adc3_through_mag_s11_s21.png",
  pha: "imgs/ACD3/adc3_through_phase_s11_s21.png",
  smith: "imgs/ACD3/adc3_through_smith_s11.png",
  dut: "imgs/ACD3/adc3_through_bench.jpg",
  offset_dut_pt: 2pt,
)


#figures_matrix(
  description: "Medición del puerto acoplado",
  port_name: "acoplado",
  dir_coupler_name: "ACD3",
  mag: "imgs/ACD3/adc3_coupled_mag_s11_s21.png",
  pha: "imgs/ACD3/adc3_coupled_phase_s11_s21.png",
  smith: "imgs/ACD3/adc3_coupled_smith_s11.png",
  dut: "imgs/ACD3/adc3_coupled_bench.jpg",
  offset_dut_pt: 0pt,
)




#figures_matrix(
  description: "Medición del puerto aislado",
  port_name: "aislado",
  dir_coupler_name: "ACD3",
  mag: "imgs/ACD3/adc3_isolated_mag_s11_s21.png",
  pha: "imgs/ACD3/adc3_isolated_phase_s11_s21.png",
  smith: "imgs/ACD3/adc3_isolated_smith_s11.png",
  dut: "imgs/ACD3/adc3_isolated_bench.jpg",
  offset_dut_pt: 0pt,
)


#pagebreak()
Ahora el cuarto acoplador direccional en stripline



#figures_matrix(
  description: "Medición del puerto de salida",
  port_name: "output",
  dir_coupler_name: "ACD4",
  mag: "imgs/ACD_tunning/acd4_through_s11_s21_mag.png",
  pha: "imgs/ACD_tunning/acd4_through_s11_s21_phase.png",
  smith: "imgs/ACD_tunning/acd4_through_s11_smith.png",
  dut: "imgs/ACD_tunning/adc4_through_bench.jpg",
  offset_dut_pt: 2pt,
)


#figures_matrix(
  description: "Medición del puerto acoplado",
  port_name: "acoplado",
  dir_coupler_name: "ACD4",
  mag: "imgs/ACD_tunning/acd4_coupled_s11_s21_mag.png",
  pha: "imgs/ACD_tunning/acd4_coupled_s11_s21_phase.png",
  smith: "imgs/ACD_tunning/acd4_coupled_s11_smith.png",
  dut: "imgs/ACD_tunning/adc4_coupled_bench.jpg",
  offset_dut_pt: 2pt,
)

#figures_matrix(
  description: "Medición del puerto aislado",
  port_name: "aislado",
  dir_coupler_name: "ACD4",
  mag: "imgs/ACD_tunning/acd4_isolated_s11_s21_mag.png",
  pha: "imgs/ACD_tunning/acd4_isolated_s11_s21_phase.png",
  smith: "imgs/ACD_tunning/acd4_isolated_s11_smith.png",
  dut: "imgs/ACD_tunning/adc4_through_bench.jpg",
  offset_dut_pt: 2pt,
)



#pagebreak()

== Analisis de resultados

En la @tab:mediciones_acoplador_915  se sintetizan los parámetros caracteristicos de los acopladores implementados, evaluados en la frecuencia de diseño  $f =$ #qty[915][MHz].

#align(center, box(width: 80%, [
  #figure(
    table(
      columns: (0.8fr, 0.8fr, 0.6fr, 0.6fr),
      inset: 6pt,
      align: horizon,
      toprule(),
      // added by this package
      table.header([*Acoplador*], [*Acoplamiento*], [*Aislación*], [*Directividad*]),
      midrule(),
      // added by this package

      "ACD1", qty[-45.58][dB], qty[-35.85][dB], qty[-9.73][dB],

      "ACD1 invertido", qty[-22.01][dB], qty[-40.34][dB], qty[18.33][dB],

      "ACD2", qty[-25.40][dB], qty[-41.87][dB], qty[16.47][dB],

      "ACD3", qty[-43.13][dB], qty[-44.10][dB], qty[0.97][dB],

      "ACD4", qty[-22.02][dB], qty[-42.97][dB], qty[20.95][dB],
      bottomrule(),
      // added by this package
    ),
    caption: "Mediciones del acoplador evaludas en 915 MHz",
  )<tab:mediciones_acoplador_915>]))
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

#image("imgs/AD8302.png", width: 50%)



#bibliography("bibliografia.bib", style: "ieee")
