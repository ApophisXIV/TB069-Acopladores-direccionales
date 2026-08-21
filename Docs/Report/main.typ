#import "template.typ": *


#show: it => basic-report(
  doc-category: "TB069 - Electromagnetismo Aplicado",
  doc-title: "Acopladores direccionales \nDiseño e implementación",
  author: "Rodriguez Guido E. (108723) - Duque Karla A. (108406)",
  affiliation: "FIUBA",
  logo: image("imgs/Logo-fiuba_big.png", width: 3cm),
  // <a href="https://www.flaticon.com/free-icons/aerospace" title="aerospace icons">Aerospace icons created by gravisio - Flaticon</a>
  language: "es",
  abstract: "Este trabajo presenta el diseño, simulación, implementación y caracterización de acopladores direccionales en tecnología microstrip y stripline sobre sustrato FR4, centrados en la frecuencia de 915 MHz. Se realizó una caracterización exhaustiva del sustrato mediante tres métodos experimentales independientes: diferencia de fase en stubs, resonadores de anillo y medición de capacitancia, con el fin de obtener parámetros precisos para el diseño. Se implementaron cuatro prototipos de acopladores, evaluando su acoplamiento, aislamiento y directividad. ",
  compact-mode: false,
  it,
)

#set math.equation(numbering: "(1)")
#import "@preview/subpar:0.2.2"
#import "@preview/fancy-units:0.1.0":


#import "@preview/fancy-units:0.1.1": qty
#import "@preview/simple-plot:0.3.0": plot
#import "@preview/booktabs:0.0.4": *
#show: booktabs-default-table-style
// #import "@preview/cetz:0.2.2":

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
      // -2.0  calc.pi,
      // -3.0 / 2.0  calc.pi,
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


= Introducción específica
A continuación se explican algunos conceptos necesarios para la elaboración del acoplador direccional, así como los métodos de medición empleados.

/* -------------------------------------------------------------------------- */
/*                            Lineas de transmision                           */
/* -------------------------------------------------------------------------- */

== Líneas de transmisión
Una línea de transmisión puede entenderse, desde una interpretación física, como un medio que permite transportar energía eléctrica, electromagnética o información, constituido por dos o más conductores metálicos, ópticos o de cualquier otro material que permita la propagación eficiente de la energía. Desde un punto de vista analítico, su modelo es necesario cuando las dimensiones físicas del sistema son comparables con la longitud de onda de la señal, de modo que los efectos de propagación no pueden ser despreciados.

=== Modelo de la línea de transmisión de parámetros distribuidos
Como se ha mencionado, el análisis se basa en el denominado modelo equivalente de parámetros distribuidos, en el cual se representan los distintos fenómenos físicos asociados a la propagación de la señal. Este modelo incluye la resistencia (R) para modelar las pérdidas en los conductores, la inductancia (L) para representar la energía en forma de campo magnético, la capacitancia (C) para representar la energía en forma de campo eléctrico y la conductancia (G) para modelar las pérdidas en el dieléctrico.

Estos parámetros están definidos por unidad de longitud y, en la práctica, dependen tanto de la geometría de la línea como de las propiedades eléctricas de los materiales que la componen. El conjunto de los cuatro parámetros recibe el nombre de modelo RLGC y constituye la base para la formulación de las ecuaciones de la línea de transmisión, derivadas por Heaviside en la década de 1880.

#figure(
  image("imgs/ilustrations/rlgc.svg", width: 65%),
  caption: [Modelo RLGC de una línea de transmisión],
)

Aplicando las leyes de Kirchhoff a un segmento infinitesimal $Delta l$, se obtienen las ecuaciones @ec:tension y @ec:corriente —denominadas ecuaciones del telegrafista— que describen la variación espacial de la tensión y la corriente #cite(<Pozar>, supplement: [p. 49]):

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ (d V(l))/(d l) = - (R + j omega L) · I(l) $ <ec:tension>],
  [$ (d I(l))/(d l) = - (G + j omega C) · V(l) $ <ec:corriente>],
)

Estas ecuaciones diferenciales de primer orden son la base para obtener una ecuación diferencial de segundo orden para la tensión y otra para la corriente, conocida como ecuación de Helmholtz (@ec:Helmholtz_tension y @ec:Helmholtz_corriente), que describe la propagación de ondas a lo largo de la línea:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ (d² V(l))/(d² l) - gamma² · V(l) = 0 $ <ec:Helmholtz_tension>],
  [$ (d² I(l))/(d² l) - gamma² · I(l) = 0 $ <ec:Helmholtz_corriente>],
)

Siendo $gamma$ la constante de propagación de la línea, esta puede expresarse como se indica en la ecuación @gamma_parametros_concentrados o en la @ec:cons_prop, donde $alpha$ es la constante de atenuación, que representa la pérdida de amplitud de la señal a lo largo de la línea, y $beta$ es la constante de fase, que describe la variación de fase de la onda durante su propagación.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ gamma = sqrt((j omega L + R) · (j omega C + G)) $ <gamma_parametros_concentrados>],
  [$ gamma = alpha + j beta $ <ec:cons_prop>],
)

Por consiguiente, la solución general de la ecuación de Helmholtz conduce a las expresiones de la tensión (@ec:Tension_TL) y corriente (@ec:Corriente_TL) a lo largo de la línea de transmisión:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ V(l) = V^+ · exp(- gamma l) + V^- · exp(gamma l) $ <ec:Tension_TL>],
  [$ I(l) = I^+ · exp(- gamma l) + I^- · exp(gamma l) $ <ec:Corriente_TL>],
)

Donde $V^+$ e $I^+$ representan las ondas incidentes que se propagan en el sentido positivo de la línea, mientras que $V^-$ e $I^-$ representan las ondas reflejadas que se propagan en sentido contrario.

=== Propagación de la señal en una línea de transmisión
La onda electromagnética en una línea de transmisión se propaga principalmente en el material dieléctrico que separa ambos conductores, es decir, lo hace en un medio material.

La onda electromagnética puede hacerlo mediante distintos modos de propagación, los cuales describen la orientación de los campos eléctrico y magnético con respecto a la dirección de propagación. Dependiendo de esta orientación, los campos pueden presentar componentes transversales, longitudinales o una combinación de ambas.

#v(-0.5cm)
#figure(
  image("imgs/modoTEMvectores.PNG", width: 5cm),
  caption: [Modo de propagación TEM],
)<fig:modo_tem>

Cuando el campo eléctrico y magnético son completamente transversales a la dirección de propagación, se presenta el modo TEM (Transversal Electromagnético), como se ilustra en la @fig:modo_tem. Este modo es más propenso a darse en frecuencias inferiores al GHz (sub-GHz) y en estructuras principalmente no dispersivas (homogéneas), como pueden ser las striplines o líneas coaxiales #cite(<Pozar>, supplement: [p.141]). En otras palabras, en estructuras donde la dispersión de la onda electromagnética fuera del confinamiento de la línea es baja o nula.

También existe el modo TE (Transversal Eléctrico), en el cual el campo eléctrico es completamente transversal a la dirección de propagación, mientras que el campo magnético presenta una componente longitudinal. En el caso contrario, el modo TM (Transversal Magnético) presenta el campo magnético transversal y el campo eléctrico con una componente longitudinal. Ambos se ilustran en las @fig:TE y @fig:TM, respectivamente.

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
  caption: [Modos de propagación transversales],
  label: <fig_modo_propagacion>,
)

Por último, el modo más propenso a ocurrir en la práctica es el denominado modo cuasi-TEM. En este modo, los campos eléctrico y magnético son casi, pero no exactamente, perpendiculares a la dirección de propagación. El modo cuasi-TEM ocurre especialmente en estructuras inhomogéneas, producto de que no toda la energía electromagnética queda confinada en la línea de transmisión, sino que una parte existe fuera del sustrato debido a las diferencias entre la permitividad del dieléctrico y el medio que la rodea, como es el caso de la línea microstrip.

Con el objetivo de simplificar el análisis, y dado que el estudio se desarrolla en la región inferior de la banda UHF#footnote[Ultra Alta Frecuencia (Ultra High Frequency). La UIT define UHF como la banda de frecuencias comprendidas entre 300 MHz y 3 GHz], se adoptará la hipótesis de propagación en modos TEM y cuasi-TEM. Esta aproximación resulta adecuada para numerosas líneas de transmisión habitualmente encontradas en la práctica y es especialmente válida para las configuraciones analizadas en este trabajo.

== Características eléctricas
Las líneas de transmisión pueden clasificarse, entre otras características, por su geometría y por las consideraciones eléctricas que se realizan para su análisis, como se presenta a continuación.

=== Línea de transmisión sin pérdidas
Representa el caso ideal donde tanto los conductores metálicos como el medio dieléctrico son perfectos. En esta condición, se asume que la resistencia en serie y la conductancia en paralelo son nulas ($R = 0$ y $G = 0$). Como consecuencia, la constante de atenuación es cero ($alpha = 0$), lo que implica que la señal se propaga indefinidamente sin reducir su amplitud.

=== Línea de transmisión larga
Esta clasificación supone líneas de transmisión que pueden considerarse infinitas para el entorno de análisis utilizado. Es decir, si para un determinado análisis consideramos la línea como infinita, asumiremos que no existen reflexiones, por lo cual toda la energía se transfiere a la carga.

=== Línea de transmisión sin distorsión
Es aquella en la que la señal de salida es una réplica exacta de la entrada, atenuada o retrasada, pero sin alterar su forma original. Como condición para que una línea de transmisión sea sin distorsión, debe cumplirse la ecuación @ec:TL_sin_distorsion, lo que pone de manifiesto que la velocidad de propagación y la atenuación no dependen de la frecuencia.

$ R/L = G/C $ <ec:TL_sin_distorsion>

=== Línea de transmisión de bajas pérdidas
En este caso, las pérdidas no son nulas, pero se consideran pequeñas en comparación con la energía reactiva almacenada por unidad de longitud ($R << omega L$ y $G << omega C$). Esto permite simplificar la constante de propagación $gamma$ y asumir que la impedancia característica $Z_0$ es puramente real:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8pt,
  [$ L C approx mu epsilon quad => quad Z_0 approx sqrt(L/C) $],
  [
    $ sigma/epsilon = G/C $],
)

En la sección @lineasdetransmision se detallan los distintos tipos de línea de transmisión según sus características eléctricas antes mencionadas.

== Características geométricas
En lo que respecta a la geometría, encontramos las líneas de transmisión planas, que son aquellas en las que los conductores que la componen son planos en su forma geométrica. Estas son las más comunes de hallar en una placa de circuito impreso (PCB), donde se encuentran conductores paralelos separados por el material dieléctrico #footnote[En el apilamiento (stack-up), la capa de dieléctrico se denomina core o prepreg según corresponda], como podría ser FR4, teflón, Kapton, cerámica, RT/Duroid, entre otros.

=== Línea de transmisión de microcinta o microstrip
Una línea microstrip consiste en un stack-up de 2 capas donde la capa superior contiene una pista (línea de transmisión) separada por un sustrato dieléctrico y en la capa inferior un plano de tierra, tal como ilustra la @fig:microstrip.

#v(-0.6cm)
#figure(
  image("imgs/ilustrations/microstripDespliegue.png", width: 40%),
  caption: [Estructura microstrip],
)<fig:microstrip>

La estructura, al estar inmersa entre dos medios materiales, implica que la señal se propagará tanto por el dieléctrico como por el otro medio (en este caso, aire). Esta discontinuidad de medios provoca que el campo electromagnético no sea puramente transversal, dando lugar al modo cuasi-TEM antes mencionado. Asimismo, se manifiestan pérdidas por radiación, ya que una fracción de la energía no queda confinada en el sustrato.

Un parámetro importante que debemos mencionar es la permitividad dieléctrica efectiva. Esta expresión es consecuencia natural de la forma en que se encuentra construida nuestra estructura, embebida entre dos medios con permitividades dieléctricas relativas diferentes. Esto pone de manifiesto que la onda propagante percibirá una permitividad dieléctrica relativa equivalente, cuyo valor se encontrará entre la $epsilon_r$ del aire#footnote[$epsilon_r("aire") = 1,00059 approx 1$] y la $epsilon_r$ del sustrato.

La consecuencia directa es que todas las ecuaciones donde hasta ahora se utilizaba la constante del material deberán contemplar esta discontinuidad, como se muestra en la @ec:vp_eff y @ec:lambda_eff, siendo $c_0$ la velocidad de la luz en el vacío y $lambda$ la longitud de onda.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 12pt,
  [$ v_p = c_0 / sqrt(epsilon_r) quad => quad v_(p_("eff")) = c_0 / sqrt(epsilon_("eff")) $ <ec:vp_eff>],
  [$
    lambda = c_0 / (f sqrt(epsilon_r)) quad => quad lambda_("eff") = c_0 / (f sqrt(epsilon_("eff")))
  $ <ec:lambda_eff>],
)

Con el objetivo de cuantificar la proporción de campo que viaja por el sustrato frente al que se dispersa, Wheeler introduce el concepto de factor de llenado efectivo (effective filling factor) #cite(<wheeler1965_filling_factor>):

$ q = (epsilon_("eff")-1)/(epsilon_r -1) $ <ec:filling_factor_wheeler>

En trabajos posteriores, Hammerstad introduce correcciones geométricas para obtener una expresión cerrada #cite(<Hammerstad>):

$ q = 1/2 · (1 + 1/sqrt(1 + 12 h/w)) $ <ec:filling_factor>

Este parámetro pondera geométricamente la relación que tiene la permitividad dieléctrica efectiva del material respecto del vacío. Despejando de la @ec:filling_factor_wheeler, podemos relacionar ambos medios mediante la @ec:e_eff_calculo, que al incorporar las modificaciones introducidas en la @ec:filling_factor resulta en la @ec:e_eff_despejado.

#grid(
  columns: (1fr, 1.5fr),
  column-gutter: 0pt,
  align: horizon,
  [$ epsilon_("eff") = 1 + q (epsilon_r - 1) $ <ec:e_eff_calculo>],
  [$ epsilon_("eff") = (epsilon_r + 1)/2 + (epsilon_r - 1)/2 · (1/sqrt(1 + 12 h/w)) $ <ec:e_eff_despejado>],
)

Se demuestra que el factor de llenado depende de parámetros geométricos de la estructura, como lo son la relación entre el ancho de pista ($w$) y el espesor del sustrato ($h$) #cite(<wheeler1965_filling_factor>). El uso de esta relación será habitual en trabajos posteriores de otros autores, como es el caso de Hammerstad y Jensen, entre otros que desarrollaremos en secciones posteriores.

Para una primera aproximación, si asumimos como constante $epsilon_r$ del sustrato, es posible notar que el valor de $q$ se encuentra acotado por factores geométricos de la estructura. Es decir, en el caso donde la pista es 'infinitamente' ancha o infinitesimalmente angosta, al tomar el límite para el parámetro $h/w$ sobre la @ec:filling_factor, observamos que el valor se encuentra acotado entre $1/2 <= q <= 1$. En consecuencia directa, los valores extremos que puede tomar la $epsilon_("eff")$ son $(epsilon_r + 1)/2 <= epsilon_("eff") <= epsilon_r$.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$ lim_(h/w -> infinity) q = 1/2 $], [$ lim_(h/w -> 0) q = 1 $],
)

Los límites obtenidos poseen una interpretación física respecto a la distribución espacial de las líneas de campo eléctrico. En el caso de una pista infinitesimalmente angosta ($h/w -> infinity$), el campo se distribuye de manera simétrica y equitativa, dado que la mitad viaja por el sustrato y la otra mitad por el aire. Por el contrario, cuando la pista es 'infinitamente' ancha ($h/w -> 0$), la estructura emula un capacitor de placas paralelas perfecto, provocando que la dispersión hacia el aire se vuelva despreciable y la totalidad del campo se confine dentro del dieléctrico, lo que fuerza que $epsilon_("eff") = epsilon_r$. Este último escenario es el que en la práctica un la estructura stripline más se asemeja.

=== Línea de transmisión stripline
Una línea stripline consiste en una estructura de transmisión compuesta por tres conductores, ubicándose dos de ellos en el exterior, separados por materiales dieléctricos de tal forma que el conductor restante queda inmerso en la interfaz de contacto de ambas capas dieléctricas. Una ilustración que clarifica lo expresado se observa en la @fig:stripline, donde los conductores de los planos superior e inferior son planos de tierra y la banda conductora central se encuentra entre dos dieléctricos, que pueden ser de igual o distinta permitividad dieléctrica.

#figure(
  image("imgs/ilustrations/striplineDespliegue.png", width: 40%),
  caption: [Estructura stripline],
)<fig:stripline>

La consecuencia inmediata de este 'blindaje' es el confinamiento del campo dentro de las fronteras de la estructura. Al no existir una interfaz sustrato-aire, la onda se propaga inmersa en un medio dieléctrico homogéneo. Por lo tanto, si ambos sustratos del 'sándwich' son de iguales características ($epsilon_r$), el factor de llenado efectivo es máximo ($q = 1$) y la permitividad percibida por la onda coincide con la del material.

Una de las principales ventajas de la stripline, producto de la homogeneidad de su estructura, es que permite asumir una propagación en modo transversal electromagnético (TEM). Sin embargo, en la práctica, debido a las imperfecciones del proceso de fabricación, en adición a las diferencias geométricas y de permitividad dieléctrica relativa de cada material que integre el stack del PCB, el modo de propagación realmente será cuasi-TEM. A pesar de estas limitaciones prácticas, la stripline sigue siendo la geometría plana que presenta la mayor similitud y aproximación al modo TEM ideal.

Por otro lado, la estructura, al presentar una forma de 'sándwich', funciona como un blindaje para el conductor central. Esto logra confinar el campo entre las placas exteriores, permitiendo despreciar la energía radiada fuera del sustrato.

Asimismo, como la onda se propaga enteramente por el sustrato, la permitividad efectiva es máxima ($epsilon_("eff") = epsilon_r$), superando a la de una microstrip del mismo material, lo que conlleva una reducción de la velocidad de fase de la señal, como podemos deducir de la @ec:vp_eff, y una reducción de la longitud de onda (@ec:lambda_eff) para la misma frecuencia.


/* -------------------------------------------------------------------------- */
/*                                 Materiales                                 */
/* -------------------------------------------------------------------------- */
== Materiales
Entre los diferentes materiales dieléctricos utilizados como sustrato en la fabricación de placas de circuito impreso (PCB) para alta frecuencia, destacan los cerámicos o teflonados comerciales, habitualmente denominados "tipo Rogers"#footnote[Rogers Corp. es un fabricante de referencia en diseños de alta frecuencia, dado que sus sustratos ofrecen una caracterización eléctrica confiable, estable y trazable. https://www.rogerscorp.com/] o "tipo Isola"#footnote[Al igual que Rogers, ofrece laminados con prestaciones notables para aplicaciones de alta velocidad. https://www.isola-group.com/], y los basados en fibra de vidrio, comúnmente llamados FR4 #cite(<globalwell2024fr>), <raypcb2023fr4>, <lee2021advancements>, <johnson2020comparative>). Este último es ampliamente utilizado en circuitos de RF que no requieren prestaciones exigentes o cuando se busca un material asequible para frecuencias menores a 3 GHz. No obstante, a medida que la frecuencia de operación se acerca a este límite, su desempeño se degrada significativamente debido a diversos factores que se analizarán en secciones posteriores.

Cuando hablamos de FR4 nos referimos al sustrato dieléctrico compuesto por un tejido de fibra de vidrio dispuesto en un entramado en forma de malla, como se observa en la @fig:malla_fr4, impregnado con resina epoxi que le otorga el característico color amarillo verdoso (@fig:fr4_lamina). Sobre este laminado se prensa el *stack-up* definitivo y se laminan las capas de cobre que conformarán las pistas del circuito.

Por otra parte, las siglas FR provienen de la denominación *Flame Retardant* (retardante de llama) Grado 4, lo que indica el cumplimiento de estándares de seguridad ante la inflamabilidad del material bajo la norma UL94 V-0. Esta propiedad autoextinguible se debe principalmente a la composición de la resina epoxi utilizada (habitualmente epiclorhidrina y bisfenol), combinada con agentes retardantes bromados. Ante la presencia de fuego directo, estos aditivos retrasan la combustión, logrando que el material extinga la llama una vez eliminada la fuente de ignición.

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
    Vista de corte del *stack-up* real de un PCB de 4 capas sobre sustrato FR4
  ]),

  columns: (0.8fr, 0.8fr, 1fr),
  gap: 0.5cm,
  gutter: 0.5cm,
  caption: [Sustrato FR4 en vistas macroscópica y microscópica],
  label: <fig:polarizacion_dielectrico>,
)

Desde el punto de vista eléctrico, particularmente en el diseño de circuitos de alta frecuencia, resultan de interés algunos parámetros que caracterizan al FR4, como lo son su permitividad relativa ($epsilon_r$) y su tangente de pérdidas ($tan(delta)$). Sin embargo, antes de continuar es necesario profundizar en la definición de estos parámetros, pues de ellos dependerá el correcto diseño, simulación e implementación del circuito.

=== Permitividad dieléctrica
La permitividad dieléctrica ($epsilon$) es una propiedad de los materiales dieléctricos que cuantifica su capacidad para polarizarse cuando son sometidos a un campo eléctrico. En ausencia de un campo externo, los momentos dipolares del material están orientados al azar, de modo que el momento dipolar neto es nulo, como se ilustra en la @fig:di_no_pol. Sin embargo, cuando se aplica un campo eléctrico, estas cargas experimentan pequeños desplazamientos respecto de su posición de equilibrio, originando dipolos eléctricos inducidos capaces de almacenar energía en el medio, como se muestra en la @fig:di_pol.

#subpar.grid(
  figure(image("imgs/ilustrations/dielectricoNoPolTAND.PNG", width: 100%), caption: [
    Dieléctrico no polarizado
  ]),
  <fig:di_no_pol>,

  figure(image("imgs/ilustrations/dielectricoSIPolTAND.PNG", width: 100%), caption: [
    Dieléctrico polarizado
  ]),
  <fig:di_pol>,

  columns: (1fr, 1fr),
  gap: 0.5cm,
  gutter: 2cm,
  caption: [Polarización del sustrato del PCB],
  label: <fig:polarizacion_dielectrico>,
)

La orientación de estos dipolos se describe mediante el vector polarización $arrow("P")$, el cual representa el momento dipolar eléctrico por unidad de volumen.

Al someter el dieléctrico a un campo eléctrico $arrow("E")_("aplicado")$, los dipolos del material se alinean y producen una acumulación de cargas de polarización en las superficies. Estas cargas generan un campo de polarización $arrow("E")_("polarización")$ en sentido opuesto al campo aplicado. Como consecuencia, el módulo del campo eléctrico efectivo dentro del dieléctrico disminuye y puede expresarse mediante la @ec:campo_electrico_total:

$ |arrow("E")_("total")| = |"E"_("aplicado")| - |"E"_("polarización")| $ <ec:campo_electrico_total>

En un medio dieléctrico lineal, la polarización es proporcional al campo eléctrico aplicado, donde $epsilon_0$ es la permitividad del vacío y $chi_e$ la susceptibilidad eléctrica#footnote[En el caso general de materiales anisotrópicos, la susceptibilidad $chi_e$ es una matriz de tensores, cuyo análisis excede el alcance del presente trabajo. Sin embargo, al asumir un medio lineal, isotrópico y homogéneo, dicha matriz se reduce a una constante.] del material, como se expresa en la @ec:vec_polarizacion:

$ arrow("P") = epsilon_0 · chi_e · arrow("E")_("aplicado") $ <ec:vec_polarizacion>

Asimismo, se define el vector desplazamiento $arrow("D") = epsilon_0 · arrow("E") + arrow("P")$. Reemplazando $arrow("P")$ mediante la @ec:vec_polarizacion y asumiendo un medio lineal, isotrópico y homogéneo, obtenemos la @ec:vector_desplazamiento:

$ arrow("D") = epsilon_0 · (1 + chi_e) · arrow("E") => arrow("D") = epsilon · arrow("E") $ <ec:vector_desplazamiento>

Finalmente, la permitividad dieléctrica del material puede expresarse mediante la @ec:permitividad_con_epsilon_r, donde $epsilon_r$ es la permitividad relativa del material respecto del vacío:

$ epsilon = epsilon_r · epsilon_0 $ <ec:permitividad_con_epsilon_r>

Hasta este punto se ha considerado que la permitividad relativa ($epsilon_r$) permanece constante. Sin embargo, en la práctica esta propiedad depende de diversos factores que alteran su valor.

El primero es la dependencia con la frecuencia. A medida que esta aumenta, los dipolos pierden la capacidad de orientarse con el campo eléctrico, por lo que la permitividad varía. Algunos mecanismos de polarización dejan de seguir las variaciones del campo eléctrico debido a sus tiempos de relajación, lo que disminuye la polarización total del material y, en consecuencia, la permitividad del dieléctrico.

En las hojas de datos proporcionadas por los fabricantes se suele indicar un valor único y considerado constante, típicamente a #qty[1][GHz]. Sin embargo, a frecuencias mayores, como las de aplicaciones de microondas o alta velocidad, la permitividad decrece.

El segundo factor es la dependencia espacial. Debido al proceso de fabricación, los materiales dieléctricos no son completamente homogéneos ni isotrópicos. En particular, en el FR4, la estructura del tejido de fibra de vidrio y las imperfecciones de manufactura introducen una anisotropía que provoca que sus parámetros característicos exhiban sensibilidad conforme a la dirección en que son analizados.

Además, el valor de la permitividad de estos materiales pertenece al campo complejo #cite(<Pozar>, supplement: [p. 10]), como se expresa en la @ec:epsilon_complejo:

$ epsilon = epsilon' - j · epsilon'' $ <ec:epsilon_complejo>

La parte real de la permitividad ($epsilon'$) se relaciona con la definición previamente expresada, que cuantifica la capacidad del dieléctrico para polarizarse cuando es sometido a un campo eléctrico.

La parte imaginaria ($epsilon''$) representa las pérdidas del medio, debidas al amortiguamiento de los momentos dipolares en vibración. En contraste, el espacio libre, al poseer una permitividad ($epsilon_0$) puramente real, no presenta estas pérdidas.

#figure(
  image("imgs/ilustrations/permitividad_compleja_modelo.png", width: 40%),
  caption: [
    Comportamiento típico de la parte real ($epsilon'$) y la parte imaginaria ($epsilon''$) de la permitividad del material en frecuencia
  ],
) <fig:modelo_grafico_epsilon_complejo>

Como se ilustra en la @fig:modelo_grafico_epsilon_complejo, cuando la curva asociada a la parte real ($epsilon'$) experimenta un rápido decaimiento, la parte imaginaria ($epsilon''$) aumenta, alcanzando máximos para las mismas frecuencias producto de los mecanismos de relajación dipolar del material dieléctrico.

A bajas frecuencias, los dipolos del material pueden alinearse sin mayor dificultad con el campo eléctrico aplicado, manteniendo un valor constante de $epsilon'$. Conforme aumenta la frecuencia, los mecanismos de polarización no logran seguir la velocidad de cambio del campo eléctrico, provocando la disminución de $epsilon'$ y la aparición de picos asociados a resonancias de $epsilon''$ producto del amortiguamiento y las pérdidas por relajación dipolar. Las frecuencias correspondientes a dichos máximos son aquellas en las que el material presentará las mayores disipaciones de energía.

En consecuencia, se presenta una relación entre la parte real y la compleja de la permitividad mediante la @ec:permitividad_con_tangente, donde se introduce el término de la tangente de pérdidas ($tg(delta)$):

$ epsilon = epsilon' · (1 - j · tg(delta)) $ <ec:permitividad_con_tangente>

=== Tangente de pérdidas
La tangente de pérdidas o tangente delta ($tg(delta)$) cuantifica la energía disipada en el dieléctrico debido a los procesos de polarización del material.

En un dieléctrico, la disipación total proviene de dos factores: las pérdidas por amortiguamiento dipolar ($omega epsilon''$) y las pérdidas por conductividad ($sigma$). Dado que ambos producen el mismo efecto disipativo sobre la onda electromagnética, no es posible distinguirlos. En consecuencia, el término $omega epsilon'' + sigma$ puede considerarse como la conductividad efectiva total, lo que permite definir la tangente delta mediante la @ec:tangente_con_sigma:

$ tg(delta) = (omega · epsilon'' + sigma) / (omega · epsilon') $ <ec:tangente_con_sigma>

Sin embargo, asumiendo un dieléctrico sin pérdidas por conductividad ($sigma approx 0$), la expresión de la tangente delta se reduce a la @ec:tangente_delta_sin_sigma:

$ tg(delta) = epsilon'' / epsilon' $ <ec:tangente_delta_sin_sigma>

Por otro lado, como se mencionó anteriormente, en la práctica los dieléctricos como el FR4 no son homogéneos ni isotrópicos, lo que afecta a parámetros de diseño como la impedancia característica y la velocidad de propagación.

A pesar de estas limitaciones, el FR4 es el material seleccionado para este trabajo debido a su bajo costo, amplia disponibilidad y facilidad de fabricación, lo que lo convierte en una opción adecuada para la implementación de estructuras de microstrip y para la caracterización experimental de parámetros dieléctricos. Si bien su naturaleza inhomogénea puede introducir pequeñas variaciones en los resultados, para la frecuencia de trabajo de #qty[915][MHz] el material sigue siendo adecuado para el análisis y validación de los métodos de caracterización propuestos.


/* -------------------------------------------------------------------------- */
/*                                 Mediciones                                 */
/* -------------------------------------------------------------------------- */

== Mediciones

Para caracterizar experimentalmente las estructuras *microstrip* presentadas en este trabajo —*stubs*, resonadores de anillo y acopladores direccionales— se emplea el análisis mediante parámetros de dispersión. Estos permiten describir el comportamiento de un dispositivo de múltiples puertos en términos de ondas incidentes y reflejadas en cada uno de sus puertos

=== Parámetros S

En circuitos de microondas, el análisis de redes se realiza comúnmente mediante parámetros de dispersión, también conocidos como parámetros S.

#figure(
  image("imgs/ilustrations/cuadripolo.png", width: 50%),
  caption: [Modelo de cuadripolo (parámetros S)],
)<fig:cuadripolo_parametros_s>

El cuadripolo de la @fig:cuadripolo_parametros_s se compone de dos puertos. El primero de ellos está integrado por los polos $A_1$ y $B_1$, que representan la onda incidente y reflejada respectivamente. De manera similar, en el segundo puerto, el polo $A_2$ representa la onda incidente y el polo $B_2$ la onda reflejada. Cada uno de los puertos puede absorber, reflejar o transmitir la señal.

Los parámetros de dispersión se definen como la relación entre la onda que sale de un puerto y la onda que incide en otro, manteniendo todos los demás puertos adaptados a la impedancia característica del sistema. Se representan con la letra $S$ seguida de un subíndice de dos dígitos ($S_(i j)$): el primero indica el puerto de salida (donde se mide) y el segundo el puerto de entrada (donde se aplica el estímulo). Por ejemplo, si se aplica el estímulo en el puerto 1 y se mide en el puerto 2, se obtiene el parámetro $S_(21)$.

Las relaciones entre los polos de cada puerto dan como resultado los siguientes parámetros:

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$ S_(1 1) = lr(B_1 / A_1 |)_(A_2 = 0) $],
  [$ S_(1 2) = lr(B_1 / A_2 |)_(A_1 = 0) $],
  [$ S_(2 1) = lr(B_2 / A_1 |)_(A_2 = 0) $],
  [$ S_(2 2) = lr(B_2 / A_2 |)_(A_1 = 0) $],
)

Los parámetros S pueden representarse en forma matricial, con $n^2$ elementos para $n$ puertos. Para un dispositivo de cuatro puertos, como el acoplador direccional analizado en este trabajo, la red se describe mediante una matriz de dispersión de $4 times 4$, donde cada elemento corresponde a una relación de transmisión o reflexión entre dos puertos.

Cada uno de estos parámetros tiene un significado propio y permite conocer magnitudes como la ganancia, la impedancia, el VSWR o las pérdidas de inserción. A continuación se detalla qué representa cada uno en el caso de un dispositivo de dos puertos:

*Coeficientes de reflexión*

- $S_(11)$: coeficiente de reflexión en la entrada ($Gamma_("in")$) → pérdidas por retorno (expresadas en dB)
- $S_(22)$: coeficiente de reflexión en la salida ($Gamma_("out")$) → pérdidas por retorno (expresadas en dB)

*Coeficientes de transmisión*

- $S_(12)$: coeficiente de transmisión inversa → pérdidas por inserción (expresadas en dB)
- $S_(21)$: coeficiente de transmisión directa → pérdidas por inserción (expresadas en dB)

=== Analizador de redes vectoriales (VNA)

Un VNA es un instrumento que permite medir los parámetros S mencionados previamente. A continuación se describe con mayor detalle la obtención de estos parámetros en una red de dos puertos.

El VNA caracteriza los parámetros S del dispositivo inyectando una señal de estímulo en uno de los puertos del DUT#footnote[Al momento de realizar una medición, el dispositivo a ensayar o caracterizar se denomina DUT (Device Under Test).], mientras que el otro puerto se termina con una carga adaptada (típicamente de $50 Omega$) cuando se mide reflexión. Acto seguido, mide la relación entre la onda reflejada y la incidente en el puerto 1, obteniendo así el parámetro $S_(11)$. Por otro lado, si se evalúa la relación entre la onda transmitida del puerto 1 al puerto 2, se obtiene el parámetro $S_(21)$ (transmisión directa). De manera similar, si se invierte el DUT (estímulo en el puerto 2 y carga en el puerto 1), se adquieren $S_(22)$ (reflexión en el puerto 2) y $S_(12)$ (transmisión inversa).

=== Calibración del VNA

Antes de cualquier medición es imprescindible realizar una calibración con el objetivo de mitigar los errores sistemáticos de origen instrumental, así como los introducidos por cables y conectores. La calibración básica de un VNA es la calibración tipo SOLT, acrónimo de *short* (cortocircuito), *open* (circuito abierto), *load* (carga) y *through* (inter-puerto). Habitualmente, esta se realiza mediante el software de calibración provisto por el fabricante del instrumento. Las tres primeras etapas (cortocircuito, circuito abierto y carga de $50 Omega$) permiten corregir los errores en la medición de coeficientes de reflexión, mientras que la etapa through es fundamental para corregir los errores en la medición de coeficientes de transmisión.

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
    caption: [Kit de calibración SOLT (SMA)],
  ),

  columns: (1fr, 1fr, 1fr),
  gutter: 1cm,
  gap: 0.5cm,
  caption: [Calibración del VNA],
  label: <fig:calibración>,
)

La calibración desplaza el plano de referencia hasta los conectores del DUT, eliminando así los errores sistemáticos del instrumento y de los cables. Para garantizar la repetibilidad y evitar daños en los conectores, se recomienda utilizar llaves torquimétricas para ajustar las conexiones y limpiar las superficies y conectores con alcohol isopropílico antes de cada medición.

/* -------------------------------------------------------------------------- */
/*           Modelos de analisis (Hammerstad - Kirschning - Sarkar)           */
/* -------------------------------------------------------------------------- */
== Modelos de análisis

En este trabajo se consideran tres modelos para caracterizar el sustrato: el modelo cuasi-estático de Hammerstad y Jensen, el modelo de dispersión de Kirschning y Jansen, y el modelo de Debye de Djordjevic-Sarkar para la permitividad compleja del dieléctrico.

=== Modelo de Hammerstad y Jensen (cuasi-estático)

El modelo de Hammerstad y Jensen #cite(<Hammerstad>) para microstrips proporciona una expresión cerrada para el cálculo de la permitividad efectiva y la impedancia característica en función de la geometría de la línea y de las propiedades del sustrato. El modelo introduce correcciones geométricas que consideran el espesor del conductor, lo que mejora la precisión en el cálculo de los parámetros de la línea.

En la @fig:error_hj se presenta una comparativa del error relativo de este modelo frente a otros modelos para un valor fijo de $epsilon_r$, lo que pone de manifiesto su precisión y su menor error respecto de otras formulaciones #cite(<ahn2012microstrip_error_hj>), #cite(<qucs_single_microstrip>).

#figure(
  image("imgs/error_modelo_hj.png", width: 60%),
  caption: [Error relativo de diferentes modelos para la impedancia característica ($epsilon_r = 9.8$)],
)<fig:error_hj>

El modelo se basa en la definición del parámetro $u = W/h$, que representa una normalización del ancho de la pista respecto de la altura del sustrato. A partir de este parámetro, se definen dos funciones auxiliares $a(u)$ y $b(epsilon_r)$, que modelan la dependencia de la permitividad efectiva con la geometría y el material:

$ a(u) = 1 + 1/49 · ln((u^4 + (u/52)^2)/(u^4 + 0.432)) + 1/18.7 · ln(1 + (u/18.1)^3) $

$ b(epsilon_r) = 0.564 · ((epsilon_r - 0.9)/(epsilon_r + 3))^0.053 $

Haciendo uso de ellas, se calcula la permitividad efectiva para el caso ideal donde el espesor del conductor es nulo ($t = 0$) mediante la @ec:epsilon_eff_hammerstad_sin_t:

$
  epsilon_("eff")(u, epsilon_r) = (epsilon_r + 1)/2 + (epsilon_r - 1)/2 · (1 + 10/u)^(-a(u) b(epsilon_r))
$ <ec:epsilon_eff_hammerstad_sin_t>

Como se mencionó anteriormente, el modelo permite calcular la impedancia característica en un medio homogéneo mediante la @ec:impedancia_hammerstad_sin_t. La expresión incluye la función $f(u)$, que modifica el término logarítmico en función de la relación $W/h$, siendo $eta_0$ la impedancia del vacío ($eta_0 approx 377 Omega$):

$ f(u) = 6 + (2 pi - 6) · exp(-(30.666/u)^0.7528) $

$ Z_(01)(u) = eta_0 / (2 pi) · ln(f(u)/u + sqrt(1 + (2/u)^2)) $ <ec:impedancia_hammerstad_sin_t>

Para considerar el espesor del conductor ($t$), Hammerstad y Jensen introducen correcciones en el ancho efectivo de la línea mediante dos factores: $Delta u_1$, para el cálculo en un medio homogéneo, y $Delta u_r$, para un medio mixto. Dichos factores se definen como:

#grid(
  columns: (1.05fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$ Delta u_1 = t/pi · ln(1 + (4 exp(1))/(t · (coth sqrt(6.517 · u))^2)) $],
  [$ Delta u_r = 1/2 (1 + 1/(cosh(sqrt(epsilon_r - 1))) · Delta u_1) $],
)

A partir de estas correcciones, se definen los anchos efectivos corregidos como $u_r = u + Delta u_r$ y $u_1 = u + Delta u_1$.

Combinando las correcciones por espesor con la impedancia $Z_(01)$, se obtienen las expresiones finales para la permitividad efectiva (@ec:epsilon_eff_hammerstad) y la impedancia característica (@ec:impedancia_hammerstad) de la línea microstrip. Estas expresiones son válidas en el régimen cuasi-estático y constituyen la base para el diseño de las líneas microstrip antes de considerar efectos dispersivos.

#grid(
  columns: (1.05fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$
    epsilon_("eff")(u, t, epsilon_r) = epsilon_("eff")(u_r, epsilon_r) · (Z_(01)(u_1) / Z_(01)(u_r))^2
  $ <ec:epsilon_eff_hammerstad>],
  [$ Z_0(u, t, epsilon_r) = Z_(01)(u_r) / sqrt(epsilon_("eff")(u_r, epsilon_r)) $ <ec:impedancia_hammerstad>],
)

=== Modelo de Kirschning y Jansen (dispersión)

El modelo cuasi-estático de Hammerstad y Jensen, descrito en el apartado anterior, no incluye la dependencia de los parámetros de la línea con la frecuencia. Para incorporar los efectos de la dispersión, se utiliza el modelo de Kirschning y Jansen #cite(<Kirschning>), el cual proporciona una expresión para la permitividad efectiva en función de la frecuencia:

$ epsilon_("eff")(f) = epsilon_r - (epsilon_r - epsilon_("eff")(f=0))/(1 + P(f)) $ <ec:epsilon_eff_Kirschning>

Este modelo parte del valor de la permitividad efectiva en régimen cuasi-estático $epsilon_("eff")(f=0)$ calculada mediante el modelo de Hammerstad y Jensen, y la corrige mediante un factor empírico de dispersión $P(f)$ que depende de la frecuencia y de la geometría de la línea:

$ P(f) = P_1 · P_2 · [(0.1844 + P_3 · P_4) · 10 · f · h]^1.5763 $

donde las funciones $P_1$, $P_2$, $P_3$ y $P_4$ vienen dadas por:

$ P_1 = 0.27488 + [0.6315 + 0.525/(1 + 0.157 · f · h)^20] · u - 0.065683 · exp(-8.7513 · u) $

$ P_2 = 0.33622 [1 - exp(-0.03442 · epsilon_r)] $

$ P_3 = 0.0363 · exp(-4.6 · u) · {1 - exp[-((f · h)/3.87)^4.97]} $

$ P_4 = 1 + 2.751 {1 - exp[-(epsilon_r/15.916)^8]} $

Es importante mencionar que en estas expresiones $f$ se expresa en gigahertz (GHz), $h$ en centímetros (cm) y el parámetro $u = W/h$ es la relación entre el ancho de la pista y la altura del sustrato, definida previamente en el modelo de Hammerstad y Jensen.

=== Modelo de Djordjevic-Sarkar (modelo de Debye del dieléctrico)

Los modelos presentados anteriormente (Hammerstad y Jensen, Kirschning y Jansen) describen la permitividad efectiva de la línea microstrip en función de la geometría y la frecuencia, pero no modelan la permitividad dieléctrica del material en función de la frecuencia. Como se mencionó previamente mediante la ecuación @ec:epsilon_complejo, la permitividad es una magnitud compleja y puede expresarse como:

$ epsilon = epsilon' · (1 - j · tan(delta)) $ <ec:epsilon_con_delta>

El modelo de Debye establece que la respuesta en frecuencia del material debe ser causal. Cuando hablamos de causalidad de un material, nos referimos a que cumple las condiciones de Kramers-Kronig #cite(<kramers-kronig>)#cite(<kramers-kronig2>), las cuales indican que la respuesta del material a una excitación no puede ocurrir antes de la excitación misma.

El modelo de Debye clásico, si bien cumple la causalidad, es válido en un rango acotado de frecuencias, ya que presenta un único tiempo de relajación (@ec:debye_clasico). Para extenderlo a un rango más amplio, sería necesario sumar $N$ términos con diferentes tiempos de relajación (@ec:debye_clasico_n_terms), lo que complejiza significativamente el modelo:

#grid(
  columns: (1.05fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$
    epsilon_r^* (omega) = epsilon_infinity + Delta_epsilon/(1 + j · omega · tau)
  $ <ec:debye_clasico>],
  [$
    epsilon_r^* (omega) = epsilon_infinity + sum_(i=1)^N (Delta_epsilon/(1 + j · omega · tau_i))
  $ <ec:debye_clasico_n_terms>],
)

Djordjevic y Sarkar observaron que, para muchos sustratos como el FR4, la distribución de tiempos de relajación no es discreta, sino continua y uniforme en escala logarítmica. Para modelar este comportamiento, proponen una extensión del modelo de Debye que considera una distribución continua de tiempos de relajación entre dos frecuencias límite, $f_("low")$ y $f_("high")$ #cite(<Djordjevic-Sarkar>).

$
  epsilon_r (omega) = epsilon'_infinity + (Delta epsilon')/(m_2 - m_1) · (ln((f_("high") + j · f)/(f_("low") + j · f))) / (ln(f_("high")/f_("low"))) - j · sigma / (omega · epsilon_0)
$<ec:Djordjevic-Sarkar_debye>

La permitividad del sustrato en este modelo se expresa en la @ec:Djordjevic-Sarkar_debye donde $epsilon'_infinity$ es la permitividad a frecuencia infinita, $Delta epsilon'$ es la variación total de la permitividad en el rango de frecuencias considerado, $m_1 = ln(omega_1)$ y $m_2 = ln(omega_2)$ son los logaritmos naturales de las frecuencias angulares límite del modelo, y $sigma$ es la conductividad del material.

Inspirados en la implementación de la biblioteca *scikit-rf*, es posible reordenar la ecuación de manera que el modelo pueda describirse a partir de parámetros mucho más accesibles, como la permitividad relativa $epsilon_r$ y la tangente de pérdidas $tg(delta)$ a una frecuencia de referencia (típicamente 1 GHz), que son los datos que suelen proporcionar los fabricantes. Este reordenamiento permite expresar el modelo en la forma $y = a · x + b$ (@ec:sistema_sarkar_reordenado_lineal), como se muestra a continuación:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 0pt,
  row-gutter: 1cm,
  align: horizon,
  [$ k = ln((f_"high" + j · f)/(f_"low" + j · f)) $], [$ epsilon_d = -tg(delta) · epsilon_r / Im(k) $],
  [$ epsilon_infinity = epsilon_r · (1 + tg(delta) · Re(k)) / Im(k) $],
  [$ epsilon_r^*(f) = epsilon_infinity + epsilon_d · k $<ec:sistema_sarkar_reordenado_lineal>],
)

Nótese que en la última expresión se ha utilizado $k$ en lugar de $f_d$, ya que $k$ contiene toda la dependencia de la frecuencia del modelo.

$
  epsilon_r (f) = epsilon_r · (1 + tg(delta) · Re(ln((f_("high") + j · f)/(f_("low") + j · f)))) / Im(ln((f_("high") + j · f)/(f_("low") + j · f))) -tg(delta) · epsilon_r / Im(ln((f_("high") + j · f)/(f_("low") + j · f))) · ln((f_("high") + j · f)/(f_("low") + j · f))
$<ec:modelo_sarkar_reacomodado>

De esta forma se puede construir un modelo que reproduce el comportamiento del material sin necesidad de ajustar múltiples parámetros resultando en la forma completa en la @ec:modelo_sarkar_reacomodado.


/* -------------------------------------------------------------------------- */
/*                     Aplicaciones de lineas transmision                     */
/* -------------------------------------------------------------------------- */

== Aplicaciones

En esta sección se presentan algunas aplicaciones prácticas de los conceptos desarrollados previamente sobre líneas de transmisión. Antes del análisis de cada caso, se realizará una breve explicación teórica de cada dispositivo para comprender el principio de su funcionamiento.

En particular, se estudiarán stubs, resonadores de anillo y acopladores direccionales, dispositivos ampliamente utilizados en circuitos de radiofrecuencia y microondas implementados sobre PCBs.

=== Stubs

Un stub es una línea de transmisión de longitud finita terminada en circuito abierto o en cortocircuito. Su principal característica es que presenta una impedancia de entrada que depende tanto de su longitud eléctrica como del tipo de terminación. La @fig:stubs_dibujo ilustra un conjunto de stubs con terminación en circuito abierto, utilizados en este trabajo para la caracterización del sustrato FR4 y la obtención de sus parámetros característicos.

#figure(
  image("imgs/ilustrations/stubs_dibujo.png", width: 45%),
  caption: [Stubs],
)<fig:stubs_dibujo>

Para un stub con terminación en circuito abierto ($Z_L = infinity$), la impedancia de entrada está dada por la @ec:stub_abierto:

$ Z(l) = -j · Z_0 · cot(beta · l) $ <ec:stub_abierto>

Por otro lado, cuando el stub tiene una terminación en cortocircuito ($Z_L = 0$), la impedancia se expresa mediante la @ec:stub_corto:

$ Z(l) = j · Z_0 · tan(beta · l) $ <ec:stub_corto>

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

Las curvas de la @fig:open_stub y la @fig:short_stub permiten observar cómo varía la impedancia del stub en función de su longitud eléctrica para ambos tipos de terminación. A partir de este comportamiento surgen diversas aplicaciones, siendo las más comunes la adaptación de impedancias, donde se emplea para compensar la parte reactiva de una carga y lograr la máxima transferencia de potencia, y el diseño de filtros de microondas, en los que actúa como un elemento reactivo implementado directamente sobre el PCB.

Otra aplicación relevante es la caracterización de dieléctricos, ya que es posible estimar la permitividad efectiva del sustrato sobre el cual se implementa la línea de transmisión. Esto resulta particularmente útil para el análisis y validación de materiales utilizados.

Para esta aplicación, la longitud física del stub se diseña para que sea un cuarto de la longitud de onda ($lambda/4$) asociada a la frecuencia de resonancia $f$, como se expresa en la @ec:longitud_stub, donde $L$ es la longitud física, $c_0$ es la velocidad de la luz en el vacío y $epsilon_("eff")$ es la permitividad efectiva del sustrato:

$ L = lambda/4 = c_0/(4 · f · sqrt(epsilon_("eff"))) $ <ec:longitud_stub>

Las condiciones de resonancia ocurren cuando la impedancia de entrada del stub se anula ($Z_("in") = 0$), haciendo que la línea se comporte como un cortocircuito a la frecuencia de interés. Por el contrario, la antiresonancia ocurre cuando la impedancia de entrada se hace infinita ($Z_("in") = infinity$).

Para un stub con terminación en circuito abierto (@fig:open_stub), las resonancias ocurren cuando $beta · l = (2k + 1) · pi/2$, es decir, para los armónicos impares ($n = 1, 3, 5, dots$), como se indica en la @ec:resonancia_open_stub. Las antiresonancias, en cambio, ocurren para los armónicos pares ($n = 2, 4, 6, dots$).

$ beta · l = (2k + 1) · pi / 2 => n = 2k + 1 $ <ec:resonancia_open_stub>

Para un stub con terminación en cortocircuito (@fig:short_stub), las resonancias ocurren cuando $beta · l = k · pi$, lo que corresponde a los armónicos pares ($n = 2, 4, 6, dots$), tal como se expresa en la @ec:resonancia_short_stub. Las antiresonancias, en este caso, ocurren en los armónicos impares ($n = 1, 3, 5, dots$), que son los puntos donde la tangente y, por lo tanto, la impedancia tienden a infinito.

$ beta · l = k · pi => n = 2k $ <ec:resonancia_short_stub>

Cabe destacar que las resonancias de los stubs permiten estimar la permitividad efectiva del sustrato, pero en este trabajo se opta por estimarlo mediante la diferencia de fase continua en todo el rango de frecuencias y validar modelos dispersivos como el de Kirschning y Jansen. La estimación por resonancias se usará como verificación cruzada.

/* -------------------------------------------------------------------------- */
/*                             Anillos resonantes                             */
/* -------------------------------------------------------------------------- */
=== Anillos resonantes

Un resonador de anillo está compuesto por un anillo y dos líneas de alimentación (feed lines), como se ilustra en la @fig:ring_dibujo. Las feed lines permiten transferir potencia hacia el resonador y extraerla desde el otro puerto. Dichas líneas se encuentran separadas del anillo por una distancia denominada gap.

#figure(
  image("imgs/ilustrations/ring_resonator_dibujo.png", width: 50%),
  caption: [Esquema básico de un resonador de anillo],
)<fig:ring_dibujo>

Chang describe que el valor del gap resulta crítico para el comportamiento del sistema, ya que determina el grado de acoplamiento entre las feed lines y el resonador #cite(<Ring_resonator>, supplement: [p. 6-7]). Este debe elegirse de manera que minimice el efecto de carga sobre el resonador sin impedir la transferencia de energía. En estas condición se denomina acoplamiento débil (loose coupling).

Bajo esta condición de acoplamiento débil, la frecuencia de resonancia puede determinarse mediante la aproximación de línea recta (straight-line approximation) propuesta por Troughton en 1969 #cite(<troughton1969>). Esta aproximación establece que la resonancia ocurre cuando el perímetro medio del anillo es igual a un múltiplo entero de la longitud de onda:

$ 2 pi R_("med") = n · lambda $ <ec:resonancia_anillo>

donde $R_("med")$ es el radio medio del anillo, $n$ es un número entero correspondiente al modo de resonancia y $lambda$ es la longitud de onda en la línea de transmisión.

Expresando la longitud de onda en función de la permitividad efectiva ($epsilon_("eff")$) dada por la @ec:lambda_eff y sustituyendo en la condición de resonancia, se obtiene:

$ epsilon_("eff") = ((n · c_0) / (f · 2 pi R_("med")))^2 $ <ec:eff_ring>

Shebani #cite(<shebani2011>) presenta curvas de diseño para el cálculo del radio medio del anillo y las dimensiones de las líneas de alimentación para diferentes sustratos como FR4, RT-Duroid 5870 y Alumina, facilitando el diseño del resonador a partir de la frecuencia de operación y la geometría de la línea. En su trabajo, el radio medio se calcula utilizando la misma condición de Troughton y la permitividad efectiva se obtiene mediante el modelo de Kirschning y Jansen.

Para complementar el análisis de los modos de resonancia, Wu y Rosenbaum desarrollan un gráfico de los diferentes modos que pueden aparecer, donde relacionan el ancho normalizado del anillo ($W/R_("med")$) con la constante de propagación normalizada ($k · R_("med")$), siendo $W$ el ancho del anillo ($W = R_e - R_i$) y $k$ el número de onda #cite(<wu_mode_chart>).

Los modos de resonancia se denominan $"TM"_("nml")$, donde $"TM"$ corresponde a transversal magnético, $n$ es la variación azimutal (alrededor del anillo) que indica cuántas longitudes de onda completas se distribuyen a lo largo de la circunferencia, $m$ es la variación radial y $l$ indica la variación en altura de la onda. Dado que el sustrato es delgado, el campo no varía en altura por lo que habitualmente $l = 0$. Posteriormente se presentarán ilustraciones obtenidas en simulación en relación al campo cercano del anillo en condiciones de resonancia y como la onda se distribuye en la estructura.

Partiendo de la condición de resonancia de Troughton (@ec:resonancia_anillo) y expresándola en función del número de onda ($k = 2pi/lambda$) se obtiene:

$ k · R_("med") = n $ <ec:aproximacion_con_k>

Esta ecuación indica que la fase acumulada de la onda al dar una vuelta completa al anillo debe ser $2 pi dot n$. Sin embargo, como advierten Wu y Rosenbaum, esta igualdad es válida para anillos de ancho angosto $W/R_("med") -> 0$. En ese caso, el campo viaja en una dirección (la circunferencia) y no hay variación radial, por lo que el modo es puramente $"TM"_("n10")$. Cuando el anillo es ancho aparecen variaciones del campo en la dirección radial que dan lugar a modos de alto orden ($m > 1$) y efectos de borde que modifican la frecuencia de resonancia; como consecuencia, el valor de $k · R_("med")$ es menor que $n$ para el modo dado.

Wu y Rosenbaum muestran que el modo $"TM"_("110")$ es el dominante para cualquier ancho de anillo y establecen que para evitar modos de alto orden se debe cumplir:

$ W/R_("med") <= 0.1 $ <ec:condicion_wu>

Una de las aplicaciones del resonador de anillo microstrip es la caracterización de propiedades de sustratos. La condición de resonancia de Troughton permite determinar la permitividad efectiva mediante la @ec:eff_ring, y adicionalmente se puede determinar la tangente de pérdidas a través del factor de calidad. Para ello es necesario cumplir con la @ec:condicion_wu para evitar modos de alto orden.

Heinola et al. presentan un método para la determinación de la constante dieléctrica y el factor de disipación de materiales FR4 utilizando un resonador de anillo microstrip #cite(<Heinola_anillos>). El método se basa en la medición de la respuesta en frecuencia del resonador con un analizador de redes, y propone un método iterativo basado en el modelo de Kirschning y Jansen para el cálculo de la constante dieléctrica en función de la frecuencia.

La obtención de la $tg(delta)$ se basa en el análisis del factor de calidad ($Q$) del modo resonante a partir de las mediciones experimentales del coeficiente de transmisión ($S_(21)$). Utilizando la frecuencia de resonancia ($f$) y el ancho de banda a -3 dB ($Delta f$), se calcula inicialmente el factor de calidad con carga ($Q_L$) mediante #cite(<Heinola_anillos>):

$ Q_L = f / (Delta f) $ <ec:Q_carga>

Dado que el resonador se encuentra acoplado a las líneas de alimentación a través de los gaps, el valor de $Q_L$ incluye el efecto de carga del circuito. Para obtener el factor de calidad sin carga ($Q_0$), que representa únicamente las pérdidas internas de la estructura, se debe compensar la pérdida de inserción en la resonancia #cite(<Heinola_anillos>, supplement: [p. 139-145]). Para un anillo acoplado simétricamente, la relación es:

$ Q_0 = Q_L / (1 - 10^(-L/20)) $ <ec:Q_sin_carga>

donde $L$ es la pérdida de inserción en dB del anillo en la frecuencia de resonancia.

Las pérdidas totales en el resonador, representadas por la inversa del factor de calidad ($1/Q_0$), son la suma de las contribuciones individuales de las pérdidas en el dieléctrico ($1/Q_d$), las pérdidas en el conductor ($1/Q_c$) y las pérdidas por radiación ($1/Q_r$) #cite(<Heinola_anillos>). De acuerdo con Belohoubek y Denlinger, las pérdidas por radiación en un resonador de anillo son despreciables debido a que son estructuras cerradas ($1/Q_r approx 0$) #cite(<belohoubek1975>), por lo que el factor de calidad dieléctrico puede calcularse con:

$ 1/Q_d = 1/Q_0 - 1/Q_c $ <ec:q_dielectrico>

La atenuación por conducción ($alpha_c$) se calcula mediante el modelo de Hammerstad y Jensen #cite(<Hammerstad>), que para una línea de microstrip depende de la geometría de la línea, de la resistencia superficial del metal y de la rugosidad del conductor. La resistencia superficial ($R_s$) se define como:

$ R_s = sqrt((omega · mu_0)/(2 · sigma)) $

donde $omega = 2pi f$ es la frecuencia angular, $mu_0$ es la permeabilidad del vacío y $sigma$ es la conductividad del cobre. Para considerar el efecto de la rugosidad superficial, Hammerstad y Jensen proponen modificar la resistencia superficial mediante:

$ R_s(Delta) = R_s(0) · [1 + 2/pi · arctan(1.4 · (Delta/delta)^2)] $

donde $Delta$ es la rugosidad efectiva del conductor y $delta$ es la profundidad de penetración. La atenuación por conducción se obtiene a partir del factor de calidad inductivo ($Q_c$), definido como:

$ Q_c = (pi)/(R_s) · (2 pi h)/(c) · f/K · u/K $

donde $K$ es el factor de distribución de corriente, que Hammerstad y Jensen aproximan mediante:

$ K = exp[-1.2 · (Z_(01)(u)/eta_0)^0.7] $

Una vez obtenido $Q_c$, la atenuación por conducción se calcula como:

$ alpha_c = (20 pi)/(ln 10) · 1/(Q_c · f · v_"eff") $

donde $v_"eff" = c / sqrt(epsilon_("eff"))$ es la velocidad de fase en la línea.

Para el cálculo de la tangente de pérdidas ($tg(delta)$), se utiliza la definición experimental de Schneider #cite(<schneider1969>), que relaciona la atenuación dieléctrica $alpha_d$ con la tangente de pérdidas:

$
  alpha_d = 8.686 · pi · (epsilon_("eff") - 1)/(epsilon_r - 1) · (epsilon_r)/(epsilon_("eff")) · (tg(delta))/(lambda)
$ <ec:schneider_loss>

Despejando $tg(delta)$ de la @ec:schneider_loss y considerando que $alpha_d$ se obtiene de la @ec:q_dielectrico mediante $alpha_d = (8.686 pi)/(Q_d · lambda)$, se llega a la expresión utilizada por Heinola et al. #cite(<Heinola_anillos>):

$ tg(delta) = (epsilon_("eff") · (epsilon_r - 1))/(Q_d · epsilon_r · (epsilon_("eff") - 1)) $ <ec:tan_delta>


/* -------------------------------------------------------------------------- */
/*                                 Acopladores                                */
/* -------------------------------------------------------------------------- */
=== Acopladores direccionales

Un acoplador direccional se modela como una red de cuatro puertos. Cuando una señal se aplica en uno de los puertos, la mayor parte de la potencia se transmite hacia el puerto de salida principal, mientras que una fracción de la señal es acoplada hacia el puerto acoplado. El último puerto se denomina puerto aislado, ya que idealmente no recibe potencia cuando la señal se propaga en la dirección prevista.

La característica fundamental de un acoplador direccional es su capacidad para acoplar potencia de forma dependiente de la dirección de propagación de la onda en la línea de transmisión, lo que permite distinguir entre ondas que se desplazan en sentidos opuestos y resulta particularmente útil para medir potencia directa y reflejada #cite(<acoplador_minicircuit>).

==== Parámetros característicos

Para determinar el comportamiento de un acoplador direccional y evaluar su desempeño en aplicaciones prácticas, se definen los siguientes parámetros característicos #cite(<acoplador_direccional_parametros>, supplement: [p. 25]):

- *Factor de acoplamiento ($C$):* Indica la relación entre la potencia aplicada al puerto de entrada y la potencia que aparece en el puerto acoplado. Se define como:
  $ C = -10 log_10(P_3 / P_1) #text([dB]) $

- *Aislamiento ($I$):* Describe la cantidad de potencia que aparece en el puerto aislado cuando se aplica una señal en el puerto de entrada. En un acoplador ideal el aislamiento sería infinito, aunque en dispositivos reales presenta un valor finito.
  $ I = -10 log_10(P_4 / P_1) #text([dB]) $

- *Directividad ($D$):* Mide la capacidad del acoplador para separar las ondas que se propagan en direcciones opuestas. Se calcula como la diferencia entre el aislamiento y el acoplamiento:
  $ D = I - C #text([dB]) $
  Una directividad elevada indica que el acoplador puede distinguir de forma efectiva entre la potencia incidente y la reflejada.

- *Pérdida de inserción ($L$):* Corresponde a la reducción de potencia que experimenta la señal al atravesar el acoplador por la línea principal. En un dispositivo ideal esta pérdida sería nula, aunque en la práctica siempre existe una pequeña atenuación debida a las pérdidas en los materiales dieléctricos y en los conductores.
  $ L = -10 log_10(P_2 / P_1) #text([dB]) $


==== Acoplador direccional de líneas acopladas

Una de las implementaciones más comunes es el acoplador direccional de líneas acopladas. Consiste en dos líneas de transmisión dispuestas en paralelo a una distancia pequeña entre sí. Esta configuración permite que la señal que se propaga por la línea principal interactúe con la línea adyacente, produciendo un acoplamiento que no afecte significativemente la línea principal.

Estos acopladores se implementan frecuentemente en forma microstrip, donde las líneas de transmisión se fabrican mediante pistas conductoras sobre un sustrato dieléctrico.

#v(-0.5cm)
#subpar.grid(
  figure(image("imgs/ilustrations/acoplador_direccional_microstrip.png"), caption: [Acoplador direccional microstrip]),
  <fig:acoplador_direccional_microstrip>,

  figure(image("imgs/ilustrations/acoplador_direccional_stripline.png"), caption: [Acoplador direccional stripline]),
  <fig:acoplador_direccional_stripline>,

  columns: (1fr, 1fr),
  gap: 0.5cm,
  gutter: -0cm,
  caption: [Acopladores direccionales microstrip y stripline],
)

Un acoplador direccional de líneas acopladas posee cuatro puertos bien definidos #cite(<Pozar>, supplement: [p.]):

- Puerto 1: puerto de entrada (input port)
- Puerto 2: puerto de salida principal (through port)
- Puerto 3: puerto acoplado (coupled port)
- Puerto 4: puerto aislado (isolated port)

Cuando una señal se aplica al puerto de entrada, la mayor parte de la potencia se transmite hacia el puerto de salida principal, mientras que una pequeña fracción es transferida a la línea acoplada (puerto 3). Idealmente, el puerto aislado no recibe señal debido a la cancelación de fase producida por la direccionalidad del dispositivo.

El nivel de acoplamiento depende directamente de la geometría de la estructura. Una menor distancia de separación entre las pistas (gap) produce un mayor acoplamiento, mientras que una separación más amplia reduce la cantidad de potencia acoplada.

==== Análisis de modos y longitud del acoplador

El comportamiento de estas estructuras se describe mediante la superposición de dos modos de propagación fundamentales: el modo par (even mode) y el modo impar (odd mode) #cite(<Pozar>).

En el modo par, las tensiones en ambas líneas son iguales y están en fase, por lo que las corrientes fluyen en la misma dirección. Como consecuencia, el plano de simetría entre las líneas se comporta como un muro magnético perfecto (PMC), donde el campo magnético tangencial es nulo. En este modo predomina la impedancia característica par $Z_(0 e)$.

Por el contrario, en el modo impar, las tensiones son iguales en magnitud pero están desfasadas $180 degree$, por lo que las corrientes circulan en direcciones opuestas. En este caso el plano de simetría actúa como un muro eléctrico perfecto (PEC), donde el campo eléctrico tangencial es nulo. Este modo tiene una impedancia característica denominada impedancia impar $Z_(0 o)$.
#figure(
  image("imgs/ilustrations/par_impar.png", width: 30%),
  caption: [Distribución de campos para el modo par e impar en líneas acopladas.],
)<fig:modos_par_impar>

Debido a que las condiciones de frontera para cada modo son distintas, las señales par e impar experimentan diferentes distribuciones de campo y acumulan fases distintas a lo largo de la región acoplada.

Para que el dispositivo presente el comportamiento deseado, las contribuciones de ambos modos deben interferir de forma destructiva en el puerto aislado y constructiva en el puerto acoplado. Esta condición de interferencia es óptima cuando la longitud física de la región donde las líneas permanecen paralelas es igual a un cuarto de la longitud de onda a la frecuencia de diseño.

Bajo esta premisa, las señales provenientes de los modos par e impar se combinan de tal forma que se logra la direccionalidad del componente. Por lo tanto, la longitud física ($L$) de la región de acoplamiento se define mediante la @ec:longitud_acoplador:

$ L = lambda / 4 $ <ec:longitud_acoplador>

==== Relación entre impedancias y acoplamiento

El factor de acoplamiento del dispositivo está determinado por las impedancias de los modos par e impar. Para un acoplador ideal simétrico, estas impedancias deben cumplir #cite(<Pozar>, supplement: [p. 353]):

$ Z_(0 e) · Z_(0 o) = Z_0^2 $

donde $Z_0$ es la impedancia característica de la línea de transmisión, típicamente $50 Omega$. Además, el factor de acoplamiento puede expresarse en términos de estas impedancias como:

$ C = 20 · log(k) => C = 20 · log ((Z_(0 e) + Z_(0 o))/(Z_(0 e) - Z_(0 o))) $ <ec:fact_c>

lo que permite determinar el diseño geométrico necesario para lograr un determinado valor de acoplamiento.

El coeficiente de acoplamiento ($k$) es la relación de tensión entre el puerto acoplado y el puerto de entrada #cite(<Pozar>, supplement: [p. 351-356]):

$ k = V_3/V_1 => k = (Z_(0 e) + Z_(0 o))/(Z_(0 e) - Z_(0 o)) $ <ec:coef_c>

Las impedancias de los modos par e impar se calculan con la @ec:impedancia_par y la @ec:impedancia_impar, donde $k$ es el coeficiente de acoplamiento (acotado entre 0 y 1) y no debe confundirse con el factor de acoplamiento $C$ expresado en dB.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$ Z_(0 e) = Z_0 · sqrt((1+k)/(1-k)) $ <ec:impedancia_par>],
  [$ Z_(0 o) = Z_0 · sqrt((1-k)/(1+k)) $ <ec:impedancia_impar>],
)

==== Acoplador híbrido de cuadratura o branch line

Además del acoplador de líneas acopladas, existen otros tipos de acopladores como el acoplador de cuadratura. Pozar señala que es un dispositivo de cuatro puertos que divide la potencia de entrada en dos salidas de igual amplitud con una diferencia de fase de $90 degree$ entre ellas #cite(<Pozar>, supplement: [p. 343-347]). Como se observa en la @fig:acoplador_cuadratura, este dispositivo se implementa mediante líneas de transmisión en forma de cuadrado, donde cada una de las líneas tiene una longitud física equivalente a $lambda/4$ calculada a la frecuencia de diseño.

#figure(
  image("imgs/ilustrations/acoplador_hibrido_dibujo.png", width: 60%),
  caption: [Acoplador en cuadratura],
)<fig:acoplador_cuadratura>

Su funcionamiento se basa en aplicar una señal al puerto de entrada (puerto 1), la cual se divide equitativamente entre los puertos 2 y 3, cada uno recibiendo la mitad de la potencia de entrada (#qty[3][dB]), mientras que el puerto 4 permanece idealmente aislado #cite(<Pozar>, supplement: [p.]).

Las impedancias características de las líneas que conforman el acoplador se eligen para lograr el acoplamiento deseado. Para un acoplador de impedancia $Z_0$ (típicamente $50 Omega$), las ramas horizontales (en serie) deben tener una impedancia de $Z_0 / sqrt(2)$, mientras que las ramas verticales (en derivación) deben tener una impedancia de $Z_0$. Esta elección de impedancias garantiza el comportamiento en cuadratura y el aislamiento del puerto 4.

Cabe destacar que este tipo de acoplador no se utilizará en el diseño práctico de este trabajo, pero su mención permite contextualizar otras alternativas dentro de la familia de acopladores direccionales.


/* -------------------------------------------------------------------------- */
/*                               Caracterizacion                              */
/* -------------------------------------------------------------------------- */
= Caracterización del sustrato

La caracterización del sustrato FR4 se realizará a través de tres métodos de medición independientes: diferencia de fase en stubs microstrip, resonadores de anillo y capacitor de placas planas paralelas.

== Método 1: diferencia de fase en stubs microstrip

El primer método consiste en la utilización de stubs de microstrip con terminación a circuito abierto de diferentes longitudes, fabricados sobre el sustrato FR4, con el objetivo de estimar la permitividad efectiva ($epsilon_("eff")$) del sustrato. Este método se basa en la relación entre la frecuencia de resonancia y antiresonancia de un stub y su longitud eléctrica, la cual depende de forma directa del parámetro $epsilon_("eff")$.

Si se intentara medir las resonancias y antiresonancias utilizando un solo stub abierto se incurriría en errores de medición como la capacitancia de borde en el extremo abierto y la longitud eléctrica añadida por la transición entre el conector SMA, la línea microstrip y el cable del VNA, lo que provocaría un desplazamiento en las frecuencias de resonancia medidas.

Para mitigar estos errores, se utiliza un par de stubs geométricamente idénticos excepto en su longitud, con una diferencia $Delta L$. Al reordenar la @ec:longitud_stub se obtienen las @ec:stub_1_L y @ec:stub_2_DL:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 0pt,
  align: horizon,
  [$ f_("stub1") = n · c_0 / (4 · L · sqrt(epsilon_("eff"))) $ <ec:stub_1_L>],
  [$ f_("stub2") = n · c_0 / (4 · (L + Delta L) · sqrt(epsilon_("eff"))) $ <ec:stub_2_DL>],
)

Al ser los stubs muy similares, los efectos parásitos son prácticamente los mismos en ambos, por lo que al restar las ecuaciones y considerar las diferencias en sus frecuencias de resonancia, el error sistemático se cancela.

El método consiste en medir el parámetro $S_11$ de cada stub y analizar la fase para identificar las frecuencias de resonancia y antiresonancia. Considerando el mismo orden armónico para cualquier par de stubs, se despeja la permitividad efectiva:

$ epsilon_("eff") = [(c_0 · n)/(4 · Delta L) · (1/f_("stub2") - 1/f_("stub1"))]^2 $ <ec:delta_pair_e_eff>

Esta ecuación depende únicamente de $Delta L$ y no de la longitud absoluta de los stubs, por lo que la exactitud del método está fuertemente ligada a la medición de las longitudes individuales y al proceso de fabricación. Promediando las estimaciones de los diferentes pares de stubs para distintos armónicos se reduce la incertidumbre, obteniendo un valor representativo de $epsilon_("eff")$.


Alternativamente, en lugar de utilizar únicamente las frecuencias de resonancia discretas, es posible extender el análisis empleando la diferencia de fase continua entre dos stubs. La permitividad efectiva se obtiene entonces a partir de la pendiente de la diferencia de fase ($Delta phi$) en función de la frecuencia:

$ epsilon_("eff")(f) = [(c_0 · Delta phi)/(4 · pi · f · Delta L)]^2 $

Este enfoque tiene la ventaja de utilizar toda la curva de fase en lugar de solo puntos aislados, lo que mejora la robustez de la estimación frente al ruido y permite obtener un modelo continuo de la permitividad en función de la frecuencia.

=== Simulación y diseño

El diseño de los stubs se realizó utilizando la calculadora de líneas microstrip integrada en Qucs (@fig:qucs_stubs_calculadora). Para una impedancia característica de $50 Omega$, se calcularon las dimensiones geométricas (ancho $W$ y longitud $L$) de cada stub empleando el modelo de Hammerstad y Jensen en su formulación cuasi-estática. Este modelo proporciona la permitividad efectiva y la impedancia característica en función de la geometría y las propiedades del sustrato.

Sobre el PCB de sustrato FR4 se diseñaron cinco stubs con distintas longitudes eléctricas, correspondientes a fracciones de la longitud de onda de la frecuencia central de 915 MHz: $lambda/2$, $lambda/4$, $lambda/8$, y dos adicionales de 50 mm y 100 mm. Estos últimos se incluyeron con el fin de generar resonancias en frecuencias diferentes y disponer de un conjunto de datos más amplio y redundante para el cálculo.

La configuración resultante es un sistema de 5 puertos cuya matriz S tiene la forma de la @ec:matriz_s_stubs, donde $S_11$ corresponde al stub de $lambda/2$, $S_22$ al de $lambda/4$, $S_33$ al de $lambda/8$, $S_44$ al de 50 mm y $S_55$ al de 100 mm.

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
  caption: [Diseño y simulación de los stubs],
)

$
  S = mat(
    S_(1 1), S_(1 2), S_(1 3), S_(1 4), S_(1 5);
    S_(2 1), S_(2 2), S_(2 3), S_(2 4), S_(2 5);
    S_(3 1), S_(3 2), S_(3 3), S_(3 4), S_(3 5);
    S_(4 1), S_(4 2), S_(4 3), S_(4 4), S_(4 5);
    S_(5 1), S_(5 2), S_(5 3), S_(5 4), S_(5 5);
  )
$ <ec:matriz_s_stubs>

Con las dimensiones obtenidas, se construyó un modelo tridimensional de cada stub sobre el sustrato FR4 en el software de simulación Altair Feko. La @fig:feko_stubs_general muestra la disposición de los stubs en el modelo de simulación. Para cada stub se realizó una simulación en dominio de la frecuencia, excitando un puerto a la vez y obteniendo el parámetro $S_11$ en el rango de 100 MHz a 6 GHz, correspondiente al mismo rango establecido para la medición física con el VNA N9923A FieldFox.

A partir de los resultados de simulación se generaron gráficos de magnitud y fase de $S_11$ para todos los stubs.

#figure(
  image("imgs/feko/feko_stubs_mag_comparativa.png", width: 100%),
  caption: [Magnitud [dB] del parámetro $S_11$, $S_22$, $S_33$, $S_44$, $S_55$],
)<fig:stubs_feko_mag>

#figure(
  image("imgs/feko/feko_stubs_phase_wrapped_comparativa.png", width: 100%),
  caption: [Fase [°] envuelta del parámetro $S_11$, $S_22$, $S_33$, $S_44$, $S_55$],
)<fig:stubs_feko_fase_wrap>

#figure(
  image("imgs/feko/feko_stubs_phase_unwrapped_comparativa.png", width: 100%),
  caption: [Fase [°] desenvuelta del parámetro $S_11$, $S_22$, $S_33$, $S_44$, $S_55$],
)<fig:stubs_feko_fase_unwrap>

En la @fig:stubs_feko_mag se identifican los picos de reflexión, correspondientes a las frecuencias donde el stub presenta una impedancia de entrada mínima, es decir, se encuentra en resonancia. Sin embargo, para este método de caracterización, el gráfico de fase (@fig:stubs_feko_fase_wrap) aporta más información, ya que permite identificar tanto las resonancias como las antiresonancias a partir de los cruces por cero.

El uso de la fase envuelta puede conducir a errores en la detección de falsos positivos, por lo que el procesamiento de los datos se realiza mediante la fase desenvuelta (@fig:stubs_feko_fase_unwrap), que elimina las discontinuidades artificiales y facilita la identificación de los múltiplos de 180°.

Además, con un objetivo didáctico, se obtuvo la distribución de campo cercano en el plano del sustrato para cada excitación individual (@fig:campo_cercano_stubs). La identificación del armónico se realiza mediante la condición $N°_("armónico") = 2 · N°_"max" - 1$.

#subpar.grid(
  figure(image("imgs/feko/stubs_campo/st_arm1.png", width: 100%), caption: [Armónico 1 $approx$ 0.418 GHz]),
  figure(image("imgs/feko/stubs_campo/st_arm2.png", width: 100%), caption: [Armónico 2 $approx$ 1.98 GHz]),
  figure(image("imgs/feko/stubs_campo/st_arm3.png", width: 100%), caption: [Armónico 3 $approx$ 2.82 GHz]),

  figure(image("imgs/feko/stubs_campo/st_arm4.png", width: 100%), caption: [Armónico 4 $approx$ 3.66 GHz]),
  figure(image("imgs/feko/stubs_campo/st_arm5.png", width: 100%), caption: [Armónico 5 $approx$ 4.50 GHz]),
  figure(image("imgs/feko/stubs_campo/st_arm6.png", width: 100%), caption: [Armónico 6 $approx$ 5.27 GHz]),

  columns: (1fr, 1fr, 1fr),
  caption: [Campo cercano para los armónicos del stub L=$lambda$/2],
  gap: 0.5cm,
  label: <fig:campo_cercano_stubs>,
)

=== Implementación

Tras la etapa de simulación, se procedió a la fabricación del PCB que contiene los cinco stubs diseñados. El proceso incluyó la transferencia del diseño realizado en KiCad mediante fotolitografía sobre el cobre y el posterior grabado con cloruro férrico. En la @fig:pcb_stubs se muestran imágenes del proceso de fabricación.

#subpar.grid(
  figure(
    image("imgs/ilustrations/pcb/stubs_pcb_pre.png", width: 65%, height: 5cm, fit: "stretch"),
    caption: [PCB durante el proceso fotolitográfico],
  ),
  figure(
    image("imgs/ilustrations/pcb/stubs_pcb.png", width: 65%, height: 5cm, fit: "stretch"),
    caption: [Resultado final],
  ),

  columns: (1fr, 1fr),
  caption: [Fabricación del PCB de stubs],
  gap: 0.5cm,
  label: <fig:pcb_stubs>,
)

=== Mediciones

Una vez fabricados los stubs, las mediciones se llevaron a cabo mediante un analizador vectorial de redes (VNA). En particular, se midió el parámetro $S_11$, correspondiente al coeficiente de reflexión en el puerto de entrada.

Para la conexión de los stubs al VNA, se soldaron conectores SMA hembra en el extremo de la línea de alimentación de cada stub. Se tuvo especial cuidado con los residuos de la soldadura para evitar la formación de capacitancias no deseadas.

Antes de realizar las mediciones, se llevó a cabo un procedimiento de calibración del VNA utilizando un kit de calibración tipo SOLT (Short-Open-Load-Through). La calibración se realizó en el plano de los conectores SMA para eliminar los efectos de fase y atenuación introducidos por el cable y los adaptadores. El VNA fue configurado con un ancho de banda de IF de #qty[300][Hz] para reducir el ruido de medición y se aplicó un promedio de 5 barridos. Finalmente se realizaron las mediciones desde #qty[100][MHz] hasta #qty[6][GHz] con 1001 puntos, lo que corresponde a un paso de #qty[5.89][MHz].

#figure(
  image("imgs/stub_un_cuarto_medicion.png", width: 50%),
  caption: [Medición del stub de $lambda$/4],
)<fig:stub_un_cuarto>

Durante la medición, cada stub fue excitado individualmente mientras los demás permanecían sin conectar (en circuito abierto). Esta configuración podría introducir cierto acoplamiento entre stubs debido a la proximidad física entre ellos. Durante el diseño se adoptó como criterio que la separación mínima entre stubs debería ser $d >= 3 · w$, donde $w$ es el ancho de la línea microstrip. Para una impedancia característica $Z_0 = 50 Omega$, $w = #qty[2.97][mm]$, resultando en $d >= 8.92$ mm.

Para evaluar cuantitativamente este efecto, se analizaron los parámetros fuera de la diagonal principal de la matriz de la @ec:matriz_s_stubs obtenidos de las simulaciones en Feko, los cuales representan la transmisión desde el stub excitado (agresor) hacia cada uno de los demás stubs (víctimas). Siendo una red pasiva y siendo excitados con el mismo nivel de señal, por simetría los parámetros $S_("ij")$ y $S_("ji")$ deberían ser iguales.

#subpar.grid(
  grid.cell(colspan: 2, figure(
    image("imgs/feko/stubs_acop/acop_100mm.png", width: 100%, height: 5cm, fit: "stretch"),
    caption: [Agresor: Stub 100 mm],
  )),
  grid.cell(colspan: 2, figure(
    image("imgs/feko/stubs_acop/acop_50mm.png", width: 100%, height: 5cm, fit: "stretch"),
    caption: [Agresor: Stub 50 mm],
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

Los resultados muestran que el acoplamiento máximo promedio observado fue menor a -20 dB en todo el rango de frecuencias, con la mayoría de los pares presentando valores inferiores a -30 dB. Se verificó que el acoplamiento en las frecuencias donde los stubs presentan resonancias armónicas entre sí se mantiene por debajo de -20 dB. Por lo tanto, se concluye que el acoplamiento mutuo entre stubs es despreciable para todo el rango de frecuencias utilizado, validando así el banco de medición.

=== Procesamiento de datos

El procesamiento de los datos de fase se realizó mediante un script en Python que opera sobre los archivos s1p que entrega el VNA donde los parámetros S se presentan con la fase envuelta en el intervalo de -180° a 180°, lo que introduce saltos abruptos artificiales cada vez que la fase acumulada supera los extremos del intervalo. Estos saltos no corresponden a fenómenos físicos sino a una ambigüedad matemática de la función arcotangente, y pueden generar falsos positivos en la detección de resonancias. Por este motivo, el script primero desenvuelve la fase de cada curva recorriendo los puntos de frecuencia y corrigiendo los saltos de 360° cuando la diferencia entre muestras consecutivas supera los 180°, recuperando así la evolución continua de la fase con la frecuencia.

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

El flujo de cálculo comienza calculando la diferencia de fase entre cada par de stubs para obtener la permitividad efectiva mediante la @ec:delta_pair_e_eff. Los pares con $Delta L < 15$ mm se descartan por producir estimaciones inestables. Con los pares válidos, se calcula la permitividad relativa del sustrato ($epsilon_r$) utilizando el modelo cuasi-estático de Hammerstad y Jensen, y luego se aplica el modelo de dispersión de Kirschning y Jansen para corregir por frecuencia. Las estimaciones de todos los pares válidos se promedian para obtener la curva representativa de $epsilon_r(f)$.

El script genera cuatro figuras que muestran las diferentes etapas del procesamiento. La @fig:er_eff_medido presenta la permitividad efectiva medida para todos los pares de stubs, donde se observa la dispersión de las estimaciones y el promedio representativo. La @fig:er_hj muestra la permitividad relativa obtenida mediante el modelo cuasi-estático de Hammerstad y Jensen, mientras que la @fig:er_kj presenta la corrección por dispersión de Kirschning y Jansen. Finalmente, la @fig:er_ds ajusta el modelo causal de Djordjevic-Sarkar a la curva representativa.

#figure(
  image("imgs/stubs/stubs_er_medido.png", width: 100%),
  caption: [Permitividad efectiva medida para todos los pares de stubs],
)<fig:er_eff_medido>

#figure(
  image("imgs/stubs/stubs_er_hammerstad.png", width: 100%),
  caption: [Permitividad relativa estimada mediante el modelo cuasi-estático de Hammerstad y Jensen],
)<fig:er_hj>

#figure(
  image("imgs/stubs/stubs_er_kirschning.png", width: 100%),
  caption: [Permitividad relativa corregida por dispersión mediante el modelo de Kirschning y Jansen],
)<fig:er_kj>

#figure(
  image("imgs/stubs/stubs_er_sarkar.png", width: 100%),
  caption: [Ajuste del modelo de Djordjevic-Sarkar],
)<fig:er_ds>

De las diez combinaciones evaluadas, se aceptaron ocho pares válidos. La permitividad relativa media obtenida es $epsilon_r = 3.40 plus.minus 0.62$, y el modelo de Djordjevic-Sarkar ajustado presenta parámetros $epsilon_infinity = 2.115$ y $Delta epsilon = 4.433$. Las frecuencias superiores a #qty[4.5][GHz] se excluyeron del análisis debido a resonancias espurias de los conectores SMA.



/* -------------------------------------------------------------------------- */
/*                                   Anillos                                  */
/* -------------------------------------------------------------------------- */
== Método 2: Resonadores de anillo

El segundo método se basa en resonadores de anillo implementados sobre el sustrato FR4, cuya condición de resonancia se establece cuando el perímetro medio del anillo es igual a un múltiplo entero de la longitud de onda guiada. Este principio permite estimar la permitividad efectiva del sustrato a partir de las frecuencias de resonancia medidas.

=== Simulación y diseño

El diseño de los resonadores de anillo se realizó siguiendo el criterio de Wu y Rosenbaum para evitar modos de alto orden, estableciendo que el ancho del anillo debe cumplir $W/R_("med") <= 0.1$. Sobre el sustrato FR4 se diseñaron cinco resonadores con frecuencias de resonancia fundamentales distribuidas en la banda de interés, cuyas dimensiones se calcularon a partir de la @ec:eff_ring utilizando el modelo de Hammerstad y Jensen para la permitividad efectiva.
#figure(image("/assets/image.png", width: 50%), caption: "Modelo 3D del anillo")
Con las dimensiones obtenidas, se construyeron modelos tridimensionales en Altair Feko y se realizaron simulaciones en dominio de la frecuencia, excitando el puerto de entrada y obteniendo el parámetro $S_(21)$ en el rango de 100 MHz a 6 GHz. Las simulaciones permitieron validar las frecuencias de resonancia diseñadas y ajustar la geometría de los acopladores para asegurar un nivel de acoplamiento adecuado entre las líneas de alimentación y el resonador.

Como fue mencionado anteriormente se presentan gráficos del campo cercano para distintas frecuencias de resonancia.

#subpar.grid(
  figure(image("imgs/Screenshot from 2026-08-21 09-59-33.png", width: 100%), caption: [Armónico 1]),
  figure(image("imgs/Screenshot from 2026-08-21 09-59-57.png", width: 100%), caption: [Armónico 2]),
  figure(image("imgs/Screenshot from 2026-08-21 10-00-24.png", width: 100%), caption: [Armónico 3]),

  columns: (1fr, 1fr, 1fr),
  caption: [Campo cercano para distintas resonancias],
  gap: 0.5cm,
  label: <fig:resonancias_anillo>,
)

=== Implementación

La fabricación de los resonadores se realizó mediante el mismo proceso fotolitográfico descripto en el método de stubs, transfiriendo el diseño de KiCad al cobre del sustrato FR4 y grabando con cloruro férrico. Cada resonador incluye dos líneas de alimentación con conectores SMA soldados en sus extremos, asegurando la conexión al VNA para las mediciones.


#figure(
  image("imgs/anillos_stubs_fr4_listos.png", width: 50%),
  caption: [PCB de anillos],
)


=== Mediciones

Las mediciones se realizaron utilizando el analizador vectorial de redes (VNA), registrando el parámetro $S_(21)$, correspondiente al coeficiente de transmisión, a lo largo del rango de 100 MHz a 6 GHz con 1001 puntos de medición. La calibración se realizó en el plano de los conectores SMA utilizando el kit SOLT, con un ancho de banda de IF de #qty[300][Hz] y un promedio de 5 barridos para reducir el ruido.

#figure(
  image("/assets/image-1.png"),
  caption: "Parámetro S21 de todos los anillos",
)

El análisis de la respuesta en frecuencia permite identificar las frecuencias de resonancia del anillo, que se manifiestan como mínimos de pérdida de inserción en el espectro de $S_(21)$. A partir de estas frecuencias, y utilizando la relación presentada en @ec:eff_ring, es posible estimar la permitividad efectiva del sustrato. Asimismo, el ancho de banda de la resonancia a -3 dB permite obtener el factor de calidad con carga ($Q_L$) del resonador mediante $Q_L = f / (Delta f)$, y a partir de la pérdida de inserción en la resonancia se obtiene el factor de calidad descargado ($Q_0$) que permite estimar las pérdidas dieléctricas del sustrato mediante los modelos de Hammerstad-Jensen para pérdidas por conducción y el modelo de Schneider para pérdidas dieléctricas, siguiendo el procedimiento descripto en la sección de anillos resonantes.

De las cinco estructuras medidas, el valor representativo de permitividad relativa obtenido fue $epsilon_r = 3.789 plus.minus 0.19$, consistente con el valor estimado por el método de stubs y la tangente de pérdidas obtenida fue $tg(delta) = 0.035 plus.minus 0.03$, dentro del rango esperado para este tipo de sustrato.



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

El objetivo del trabajo es diseñar, simular y caracterizar un acoplador direccional microstrip centrado en 915 MHz, capaz de manejar una potencia de 5 W. Este componente formará parte del proyecto general y será destinado a la medición de potencia reflejada y el monitoreo del ajuste de antena, permitiendo obtener el coeficiente de reflexión a partir de la señal acoplada. sim ebargo, el presente trabajo se acota a la realización 
de un acoplador direccional.

El desarrollo se realizará utilizando uSimmics (Qucs-studio) como herramienta principal de simulación, siendo un software libre y sin costo permitiendo analizar y simular las líneas acopladas y una implementación alcanzable en el marco del proyecto, aunque los resultados podrían contrastarse posteriormente con herramientas como Feko.

Por otro lado el diseño teórico se basará en el modelo de modos par e impar (even/odd), a partir del cual se determinarán los parámetros de acoplamiento ($C$) y directividad ($D$). Estos parámetros serán válidados mediante simulaciones electromagnéticas.

Con el fin de optimizar la respuesta en frecuencia del acoplador y lograr un acoplamiento que si bien todavia no fue definido con rigurosidad será próximo a #qty[-30][dB] en la frecuencia de trabajo se realizará un barrido paramétrico sobre el espaciado entre líneas, ancho de pista y longitud de acoplamiento 

Finalmente, el acoplador se fabricará sobre el mismo sustrato caracterizado (FR4), se medirán sus parámetros $S_(11)$, $S_(21)$, $S_(31)$ y $S_(41)$ mediante un analizador vectorial de redes (VNA), y se evaluará la directividad obtenida comparando la potencia acoplada hacia los puertos acoplado y aislado.

== Implementación del acoplador direccional


Al momento de la implementación física del dispositivo en un PCB se decició hacerlo mediante un proceso fotolitografico. Dicho método fue escogido con el fin de minimizar las variaciones físicas en las dimesiones de las estructuras debido a que la exactitud de los métodos de estimación utilizados es altamente sensible a la geometría.



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


En la @fig:pcb_acoplador_direccional se puede notar los diseños que se obtuvieron mendiante el proceso por fotolitografia y los experiemntales con cinta de cobre donde se realizarán las distintas mediciones. 

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



#bibliography("bibliografia.bib", style: "ieee")
