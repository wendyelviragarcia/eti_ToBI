#	Eti_ToBI v.7 (2018)
#
#
#
#	This is a tool that automatically labels intonational events according to the Sp_ToBI and Cat_ToBI current systems. T
#	The system consist on a Praat script that assigns ToBI labels from lexical data introduced by the researcher and the
#	acoustical data that it extracts from sound files.  The reliability results for both Cat_ToBI and Sp_ToBI corpora shows
#	a level of agreement equal to the one shown by human transcribers among them in the literature.
#
#				DESCRIPTION
#
#				INSTRUCTIONS
#	0. Needs 
#		a) a folder with sounds (a sentence in each wav)
#		b) textgrid with the same name than the sound and interval syllables and a mark for the stressed syllables
#	
#	Wendy Elvira-García (2013-2015). Eti-ToBI. [praat script]Retrieved from http://stel.ub.edu/labfon/en/praat-scripts
#	w e n d y e l v i r a g a r c i a @ g m a i l . c o m
#	
#	Laboratori de Fonètica (Universitat de Barcelona)
#
#
#						LICENSE
# Copyright (C) 2015  Wendy Elvira-García
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You can find the terms of the GNU General Public License here
# http://www.gnu.org/licenses/gpl-3.0.en.html


#####	FORMULARIO	##########
form Sp_ToBI Cat_ToBI transcriber
	
	sentence folder /Users/weg/Desktop/paraprobar
	# EN EL LAB
	word Marca_de_tonica ˈ
	comment ¿En que número de tier está la marca de tonicidad?
	integer Tier_tonicidad 1
	comment ¿Tienes marcados los break indices?
	boolean BI 1
	#comment ¿En qué número de tier?
	integer Tier_BI 2
	
	comment ¿En qué número de tier quieres hacer la inserción de los tonos?
	integer Tier_Tones 3
	
	real umbral_(St) 1.5
	real umbral_upstep_(St) 6.0
	comment Elige los tipos de etiquetaje:
	boolean Etiquetaje_superficial 1
	boolean Etiquetaje_profundo 1
	boolean Etiquetaje_normalizado 1
	#comment Indica la lengua del etiquetaje fonológico:
	optionmenu Lengua 2
	option General
	option Sp_ToBI
	option Cat_ToBI
	option Fri_ToBI
	#option MAE_ToBI
	#option It_ToBI
	comment ¿Quieres parar para corregir?
	boolean correccion 0
	boolean create_picture 1
integer iniciar_en_archivo 1

endform

if etiquetaje_profundo = 1

	beginPause: "Tipo de etiquetaje"
		comment: "¿Cuáles de estas etiquetas quieres que aparexcan en el etiquetaje profundo?"
		 optionMenu: "Displaced_prenuclear", 1
		 option: "L+<H*"
		 option: "L*+H"
		 optionMenu: "Upstep", 1
		 option: "L+¡H*"
		 option: "L+H*"
		 optionMenu: "Pretonica_upstep", 2
		 option: "¡H+L*"
		 option: "H+L*"
		 optionMenu: "Descenso_tonica", 2
		 option: "H*+L"
		 option: "H*"
		 optionMenu: "Ascenso_tardio", 2
		 option: "L* LH%"
		 option: "L* H%"
		 optionMenu: "Tritonal_Argentina", 2
		 option: "L+H*+L"
		 option: "no"

     		comment ("Cuando acabes, clica Continuar para empezar")
    	clicked = endPause ("Continuar", 2)
endif

##############		VARIABLES	######################
rango$ = "60-600"
from = iniciar_en_archivo
a = displaced_prenuclear
b= upstep
c= descenso_tonica
d = ascenso_tardio
f = tritonal_Argentina
g= pretonica_upstep
#comment ¿Quieres el etiquetaje en un nuevo tier?
	nuevo_tier_Tones = 1

if etiquetaje_normalizado=1 and etiquetaje_profundo =0
	pause La estandarización parte del etiquetaje profundo.
endif
if etiquetaje_profundo =1 and etiquetaje_superficial =0
	pause El etiquetaje profundo parte del etiquetaje superficial.
endif

f0_max = extractNumber (rango$, "-")
f0_max$ = "'f0_max'"
f0_min$ = "'rango$'" - "'f0_max$'"
f0_min$= "'f0_min$'" - "-"
f0_min = 'f0_min$'

numberOfLetras = 15
umbralnegativo = umbral - (2*umbral)
ultimatonica = 0
etiquetaprofunda$ = "* no"
etiquetatonoprofundo$ = " * aguda"
etiquetafinalprofunda$ = "\% "

##############	BUCLE GENERAL 	######################
# Crea la lista de objetos desde el string
Create Strings as file list: "list", folder$ + "/" + "*.wav"
#Hace el bucle con ello
numberOfFiles = Get number of strings

if numberOfFiles = 0 
	Create Strings as file list: "list", folder$ + "/" + "*.WAV"
	numberOfFiles = Get number of strings
endif

if numberOfFiles = 0 
	exit: "There are no .wav or .WAV files in folder" + folder$
endif


#bucle archivos
for ifile from 'from' to numberOfFiles
echo Working on file 'ifile'
	select Strings list
	archivosonido$ = Get string: ifile
	base$ = archivosonido$ - ".wav"
	base$ = base$ - ".WAV"

	#reads sound 
	mySound = Read from file: folder$ +"/" + archivosonido$

	#reads grid
	myText = Read from file: folder$ + "/" +base$ + ".TextGrid"

	#########	CREA OBJETOS ########



	select Sound 'base$'
	#elimina todas las frecuencias superiores a 900Hz para minimizar los Pitch de las fricativas que están a 2000 y 3000 Hz
	Filter (stop Hann band): 900, 20000, 100
	#sacar la gama
	select Sound 'base$'_band
	 To Pitch... 0.001 f0_min f0_max
	select Pitch 'base$'_band
	Rename: base$

	printline frase 'base$'
	f0medial = do ("Get mean...", 0, 0, "Hertz")
	printline mediana de la frase: 'f0medial'
	#minpitch = do ("Get minimum...", 0, 0, "Hertz", "Parabolic")
	#maxpitch = do ("Get maximum...", 0, 0, "Hertz", "Parabolic")
	#cuantiles teoría de Hirst (2011) analysis by synthesis of speach melody
	q25 = Get quantile: 0, 0, 0.25, "Hertz"
	q75 = Get quantile: 0, 0, 0.75, "Hertz"
	minpitch = q25 * 0.75
	maxpitch = q75 * 1.5

	gama = maxpitch - minpitch

	terciogama = gama/3
	tercio1 = minpitch + terciogama
	tercio2 = minpitch + (2*terciogama)
	tercio3 = minpitch + (3*terciogama)


	# esto estiliza la curva pero cuando la frase es larga aumenta mucho la frecuencia de la primera parte. Por eso primero saco la mediana de la frase.
	#do ("Kill octave jumps")
	do ("Interpolate")
	#esto es para que no salgan valores como undefined (salen si hay partes sordas o ensordecidas)
	do ("Down to PitchTier")


	#########	EMPIEZA EL SCRIPT		#####################
	select TextGrid 'base$'
	numberOfIntervals = Get number of intervals: tier_tonicidad
	i = 1
printline numberOfIntervals 'numberOfIntervals'

	### sustitucion de caracteres
	marcatonicacompleja$ = "\'1"
	if marca_de_tonica$ = marcatonicacompleja$
		select TextGrid 'base$'
		do ("Replace interval text...", tier_tonicidad, i, numberOfIntervals, "\'1", "ˈ", "Regular Expressions")

		marca_de_tonica$ = "ˈ"
	endif


	#####################


	if  nuevo_tier_Tones = 1
		Insert point tier... 'tier_Tones' "Tones"
	endif
	if  etiquetaje_profundo = 1
		tier_profundo = tier_Tones + 1
		Insert point tier... 'tier_profundo' "Tones II"
	endif

	#bucle silabas
	if bI =1
		numberOfIPs = Count points where: tier_BI, "is equal to", "4"
		myPointProcess = Get points: tier_BI, "is equal to", "4"
		endIntervalIP =1
	else
		numberOfIPs = 1
		selectObject: "TextGrid " + base$ 
		endOfSound= Get end time
		lastInt = Get number of intervals: tier_tonicidad
		lastBoundary = Get end point: tier_tonicidad, lastInt
		myPointProcess = Create empty PointProcess: base$, 0, endOfSound
		Add point: lastBoundary
		endIntervalIP =1
	endif
	
	startIntervalIP = 1
	iIP=0
	for iIP from 1 to numberOfIPs
		# get la aparicion iIP de las ip
		
		selectObject: myPointProcess
		timeOf4Boundary = Get time from index: iIP
		select TextGrid 'base$'
		endIntervalIP = Get interval at time: tier_tonicidad, timeOf4Boundary
		endIntervalIP =endIntervalIP-1
		actualInterval=0
		tonicastotalesfrase = 0


		i=0
		for i to endIntervalIP-startIntervalIP
		printline START 'startIntervalIP'
		printline ENDIP 'endIntervalIP'

			actualInterval = startIntervalIP + i

			if actualInterval< numberOfIntervals

				#for i to numberOfIntervals
				numberdesdeelfinal = endIntervalIP - actualInterval
				select TextGrid 'base$'

				########################## 	cálculo de tónicas 	####################################
	printline ACTUALINTERVAL 'actualInterval'
				labeli$ = Get label of interval: tier_tonicidad, actualInterval

				# Hago un array que guarda los caracteres en variables diferentes
				for letra from 1 to numberOfLetras
					labeltext$[letra] = mid$ ("'labeli$'", letra)
				endfor

				if labeltext$[1] = marca_de_tonica$
					ultimatonica = actualInterval
					
					if ultimatonica < 1
						exit No hay ninguna marca de tónica en esta frase
					endif
				printline
				printline ANÁLISIS TÓNICA DEL INTERVALO 'ultimatonica'
					tonicastotalesfrase = tonicastotalesfrase + 1
					startingpointtonica = Get start point... 'tier_tonicidad' 'actualInterval'
					endingpointtonica = Get end point... 'tier_tonicidad' 'actualInterval'
					durtonica = endingpointtonica - startingpointtonica
					mediotonica = startingpointtonica + (durtonica/2)

					numberOfIntervalPretonica = actualInterval - (1)
					startingpointpretonica = Get start point... 'tier_tonicidad' 'numberOfIntervalPretonica'
					endingpointpretonica = Get end point... 'tier_tonicidad' 'numberOfIntervalPretonica'
					durpretonica = endingpointpretonica - startingpointpretonica
					mediopretonica = startingpointpretonica + (durpretonica/2)
						printline tonica centro: 'mediotonica'
					numberOfIntervalPostonica = actualInterval + 1
					startingpointpostonica = Get start point... 'tier_tonicidad' 'numberOfIntervalPostonica'
					endingpointpostonica = Get end point... 'tier_tonicidad' 'numberOfIntervalPostonica'
					durpostonica = endingpointpostonica - startingpointpostonica
					mediopostonica = startingpointpostonica + (durpostonica/2)
					printline inicio postónica: 'startingpointpostonica' medio postonica: 'mediopostonica' final postónica: 'endingpointpostonica'


					#obtención de valores pitch
					select PitchTier 'base$'
					f01pre = Get value at time... 'startingpointpretonica'
					f02pre = Get value at time... 'mediopretonica'
					f03pre = Get value at time... 'endingpointpretonica'
					if numberOfIntervalPretonica = 1
						f02pre = Get value at time... 'startingpointtonica'
						f01pre = Get value at time... 'startingpointtonica'
						f03pre = Get value at time... 'startingpointtonica'
					endif
							printline pretonica 'mediopretonica'

					f01ton = Get value at time... 'startingpointtonica'
					f02ton = Get value at time... 'mediotonica'
					f03ton = Get value at time... 'endingpointtonica'
					f01pos = Get value at time... 'startingpointpostonica'
					f02pos = Get value at time... 'mediopostonica'
					f03pos = Get value at time... 'endingpointpostonica'

					printline F01 'f01pos' F02 'f02pos' F03 'f03pos'

					select Pitch 'base$'
					f0tonmax = Get maximum: startingpointtonica, endingpointtonica, "Hertz", "Parabolic"
					if f0tonmax=undefined
						@undefined: f0tonmax, endingpointtonica
						f0tonmax = value
					endif
					f0tonmin = Get minimum: startingpointtonica, endingpointtonica, "Hertz", "Parabolic"
					if f0tonmin=undefined
						@undefined: f0tonmin, endingpointtonica
						f0tonmin = value
					endif

					f0targetpos = Get maximum: startingpointpostonica, endingpointpostonica, "Hertz", "Parabolic"
					if f0targetpos= undefined
						@undefined: f0targetpos, endingpointpostonica
						f0targetpos = value
						if f0targetpos = undefined
							f0targetpos = minpitch
						endif
					endif

					#####	DIFERENCIA EN ST ENTRE DOS FRECUENCIAS	###############

					difpreton = (12 / log10 (2)) * log10 ('f02ton' / 'f02pre')
					diftonpos = (12 / log10 (2)) * log10 ('f02pos' / 'f02ton')
					difton2pos3 = (12 / log10 (2)) * log10 ('f03pos' / 'f02ton')
					difpremaxton = (12 / log10 (2)) * log10 ('f0tonmax' / 'f02pre')
					diftonton = (12 / log10 (2)) * log10 ('f03ton' / 'f01ton')
					diftontargetpos = (12 / log10 (2)) * log10 ('f0targetpos' / 'f0tonmin')
					diftonmintonmax = (12 / log10 (2)) * log10 ('f0tonmax' / 'f0tonmin')
			printline En el pretonema difpreton 'difpreton' diftonpos 'diftonpos' difpremaxton 'difpremaxton' diftonton 'diftonton' diftonmintonmax 'diftonmintonmax' diftontargetpos 'diftontargetpos'

					################	FORMULAS	####################

					#########	Fórmulas que calculan el pitch accent prenuclear ########################
					#En realidad calculan todos los acentos depués el nuclear se rescribirá
					etiquetatono$= "prenuclear"
					etiquetatonoprofundo$= "prenuclear"

					###############	Tonos a partir de la mediana ##################
					if abs (difpreton) < 'umbral' and abs (diftontargetpos) < 'umbral' and f02ton < tercio2
						etiquetatono$ = "L*"
						etiquetatonoprofundo$ = "L*"
		printline formula pre L*
					endif

					if abs (difpreton) < 'umbral' and abs (diftontargetpos) < 'umbral' and f02ton >= tercio2
						etiquetatono$ = "H*"
						etiquetatonoprofundo$ = "H*"
		printline formula pre H*
					endif

					#CALCULO DEL TONO EN VEZ DE POR TERCIOS POR DECLINACION
					select TextGrid 'base$'
					numeropuntosahora = Get number of points: 'tier_Tones'
					printline numeropuntosahora 'numeropuntosahora'
					if numeropuntosahora >=2
						labeltonicaanterior$ = Get label of point: tier_Tones, numeropuntosahora-1
						tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora-1
							select PitchTier 'base$'
							f0_puntoanterior = Get value at time: tpuntoanterior
							select TextGrid 'base$'
							intervaloptoanterior = Get interval at time: tier_tonicidad, tpuntoanterior
							iniciointervaloanterior = Get start point: tier_tonicidad, intervaloptoanterior
							finintervaloanterior = Get end point: tier_tonicidad, intervaloptoanterior
							select Pitch 'base$'
							f0maxtonicaanterior = Get maximum: iniciointervaloanterior, finintervaloanterior, "Hertz", "Parabolic"
							if f0maxtonicaanterior = undefined
								@undefined: f0maxtonicaanterior, finintervaloanterior
										f0maxtonicaanterior = value
							endif
							difconlaanterior = (12 / log10 (2)) * log10 (f0maxtonicaanterior / f0_puntoanterior)
							printline difconlaanterior 'difconlaanterior'

						if ('difconlaanterior' > 'umbralnegativo') and ((labeltonicaanterior$ = "H*") or (labeltonicaanterior$ = "L*+H") or (labeltonicaanterior$ = "L+H*") or (labeltonicaanterior$ = "(L+H*)+H")or (labeltonicaanterior$ = "L+(H*+H)") or (labeltonicaanterior$ = "L*+(H+H)") or (labeltonicaanterior$ = "(L*+H)+H)") or (labeltonicaanterior$ = "(L+H*)+L)"))
							pitchaccent$ = "H*"
							etiquetatono$ = "H*"
							etiquetatonoprofundo$ = "H*"
							tonicaH= 1
						else
							pitchaccent$ = "L*"
							etiquetatono$ = "L*"
							etiquetatonoprofundo$ = "L*"
							tonicaH= 0
						endif
					endif
					printline pitchaccent 'pitchaccent$'


					####### Desacentuación
					if difpreton < 'umbralnegativo' and diftonpos < 'umbralnegativo'
						etiquetatono$ = "des"
						etiquetatonoprofundo$= "des"
		printline formula pre des
					endif


					#etiqueta muy simple debería mirar si el target está en la postónica
					if diftonton > umbral
						etiquetatono$ = "L+H*"
						etiquetatonoprofundo$= "L+H*"
					endif

					if difpreton > umbral
						etiquetatono$ = "L+H*"
						etiquetatonoprofundo$ = "L+H*"
					endif

					if diftontargetpos > umbral
						etiquetatono$ = "L*+H"
						etiquetatonoprofundo$ = "L*+H"
					endif
					
					if diftontargetpos < umbralnegativo
						etiquetatono$ = "H*+L"
						etiquetatonoprofundo$ = "H*+L"
					endif
					
					if difpreton < umbralnegativo
						etiquetatono$ = "H+L*"
						etiquetatonoprofundo$ = "H+L*"
					endif

					#fórmula para las preguntas del que solo aplica al catalán. Bajada significativa entre incio tónica y final tónica.
					if lengua = 3 and diftonton < 'umbralnegativo'
						etiquetatono$ = "H+L*"
						etiquetatonoprofundo$= "H+L*"
		printline formula pre H+L* preg que
					endif

					#si puedes mira el pto anterior y pon si el plateu es alto o bajo dependiendo del tono anterior
					select TextGrid 'base$'
					numeropuntosahora = Get number of points: 'tier_Tones'

					if abs (difpreton) < umbral and abs (diftonpos) < 'umbral' and (numeropuntosahora >= 1) and (diftonton > umbralnegativo)
						labeltonicaanterior$ = Get label of point: tier_Tones, numeropuntosahora
						if (labeltonicaanterior$ = "H*") or (labeltonicaanterior$ = "L*+H") or (labeltonicaanterior$ = "L+H*") or (labeltonicaanterior$ = "(L+H*)+H")or (labeltonicaanterior$ = "L+(H*+H)") or (labeltonicaanterior$ = "L*+(H+H)")or (labeltonicaanterior$ = "(L*+H)+H)")
							#ves a buscar el valor de del punto anterior y si del punto anterior al punto de ahora no pasa el umbral negativo etiquetalo como H*
							select TextGrid 'base$'
							tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora
							select PitchTier 'base$'
							f0_puntoanterior = Get value at time: tpuntoanterior
							difconlaanterior = (12 / log10 (2)) * log10 ('f02ton' / 'f0_puntoanterior')
							if difconlaanterior > 'umbralnegativo'
								etiquetatono$ = "H*"
								etiquetatonoprofundo$ = "H*"
							endif
						endif
					endif


					########################################################

					if abs (diftonmintonmax) < 'umbral' and diftontargetpos >= 'umbral'
						etiquetatono$ = "L*+H"
						etiquetatonoprofundo$ = "L*+H"
		printline fórmula prenúcleo 'labeli$' L*+H
					endif

					if abs (diftonmintonmax) < 'umbral' and diftonpos < 'umbralnegativo'
						etiquetatono$ = "H*+L"
						if c = 2
							etiquetatonoprofundo$ = "H*"
						endif
						if c = 1
							etiquetatonoprofundo$ = "H*+L"
						endif
		printline fórmula prenúcleo 'labeli$' H*+L
					endif
					######


					# H+L* PUESTO PARA QUE DIGA DESACENTUADO SI VIENE DE OTRO TONO
					# hay una diferencia en la tónica que pasa el umbral, esa diferencia es negativa, y de la tónica al target de la postónica no pasa el umbral
					if (diftonmintonmax > 'umbral') and (diftonton < 0) and (abs (diftontargetpos) < 'umbral')
						etiquetatono$ = "H+L*"
						etiquetatonoprofundo$ = "H+L*"

						if lengua = 2 or lengua = 3
							select TextGrid 'base$'
							numeropuntosahora = Get number of points: 'tier_Tones'
							printline  numeropuntosahora 'numeropuntosahora'
							if numeropuntosahora >=1
								labeltonicaanterior$ = Get label of point: tier_Tones, numeropuntosahora
								if labeltonicaanterior$ ="L*+H" or labeltonicaanterior$ ="H+(L*+H)"
									tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora
									intervaloultimotono = Get interval at time: tier_tonicidad, tpuntoanterior
									intervalotarget = intervaloultimotono + 1
									inicio_target = Get start point: tier_tonicidad, intervaloultimotono
									fin_target = Get end point: tier_tonicidad, intervaloultimotono+1
									select Pitch 'base$'
									f0_targetanterior = Get maximum: inicio_target, fin_target, "Hertz", "Parabolic"
									if f0_targetanterior=undefined
										@undefined: f0_targetanterior, fin_target
										f0_targetanterior = value
									endif

									#select PitchTier 'base$'
									#f0_targetanterior = Get value at time: fin_target
									difconlaanterior = (12 / log10 (2)) * log10 ('f02pre' / 'f0_targetanterior')
									printline difconlaanterior 'difconlaanterior'
									if difconlaanterior < umbralnegativo
										etiquetatono$ = "H+L*/L*"
										etiquetatonoprofundo$ = "L*"
										printline fórmula prenúcleo 'labeli$' "H+L*/L*"
									endif
								endif
							endif
						endif
					endif

					# las replicas sevillans #PARA LAS DE QUE CON PRETÓNICA EXTRALTA DEL CATALAN
						if (lengua =3 or lengua = 2) and (difpreton < 'umbralnegativo') and (abs (diftonpos) < 'umbral') and (f02pre>f01pre) and (f02pre>f03pre)
							etiquetatono$ = "\!dH+L*"
							if g = 1
							etiquetatonoprofundo$ = "\!dH+L*"
							else
							etiquetatonoprofundo$ = "H+L*"
							endif
							printline fórmula prenúcleo 'labeli$' ¡H+L* pretónica extraalta
						endif
					

					#subida entre la pretonica y la tónica y entre la tónica y la postónica. Y los dos movimientos pasan el umbral.
					if difpreton >= 'umbral' and diftonpos>= 'umbral'
						etiquetatono$ = "L+H*+H"
			printline fórmula prenúcleo 'labeli$' L+H*+H
						if abs (difpreton) < abs (diftonpos)
							etiquetatono$ = "(L+H*)+H"
							etiquetatonoprofundo$ = "L*+H"
							if a =1
								etiquetatonoprofundo$= "L+<H*"
							endif
						else
							etiquetatono$ = "L+(H*+H)"
							etiquetatonoprofundo$ = "L*+H"
							if a =1
								etiquetatonoprofundo$= "L+<H*"
							endif
						endif
						if f = 1
							etiquetatonoprofundo$= "L+H*+L"
						endif
					endif


					# subida entre la pretónica y la tónica con el pico al final la postónica o más allá
					if difpreton> umbral and f03pos > f01pos
						etiquetatono$ = "L*+H"
						etiquetatonoprofundo$= "L*+H"
					endif

					# subida entre la pretónica y la tónica con el pico entre el final de la tónica y el principio de la postónica (L+H* clásico)
					if difpreton >= 'umbral' and f01pos >= f03pos
						etiquetatono$ = "L+H*"
						etiquetatonoprofundo$ = "L+H*"

		printline fórmula prenúcleo 'labeli$' L*+\!dH*
					endif

					#  ETIQUETA CUESTIONABLE subida entre la pretónica y la tónica con el pico en el centro de la postónica
					if (diftonmintonmax >= 'umbral') and (diftonton >0) and (f01pos >= f02ton) and (f02pos >= f01pos) and (f02pos >= f03pos)
						etiquetatono$ = "L+H*+H"
						printline fórmula prenúcleo 'labeli$' L+H*+H
						if abs (diftonmintonmax) < abs (diftonpos)
							etiquetatono$ = "(L+H*)+H"
							etiquetatonoprofundo$ = "L*+H"
							if a =1
								etiquetatonoprofundo$= "L+<H*"
							endif
						else
							etiquetatono$ = "L+(H*+H)"
							etiquetatonoprofundo$ = "L*+H"
							if a =1
								etiquetatonoprofundo$= "L+<H*"
							endif
						endif
					endif





					# Una bajada que pasa el umbral de la pretónica a la tónica y una subida en la postónica que también pasa el umbral
					if difpreton < 'umbralnegativo' and diftontargetpos >= 'umbral'
						#si el movimiento es mayor de la pretónica a la tónica
						if abs (difpreton) >= abs (diftontargetpos)
							etiquetatono$ = "H+(L*+H)"
							etiquetatonoprofundo$= "H*+L"
						#si el movimiento es mayor de la tónica a la postónica
						else
							etiquetatono$ = "(H+L*)+H"
							etiquetatonoprofundo$= "L*+H"
						endif

						if lengua = 2 or lengua = 3
							select TextGrid 'base$'
							numeropuntosahora = Get number of points: 'tier_Tones'
							printline  numeropuntosahora 'numeropuntosahora'
							if numeropuntosahora >=1
								labeltonicaanterior$ = Get label of point: tier_Tones, numeropuntosahora
								if (labeltonicaanterior$ = "L*+H") or (labeltonicaanterior$ ="L+(H*+H)") or (labeltonicaanterior$ ="(L+H*)+H")
									tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora
									intervaloultimotono = Get interval at time: tier_tonicidad, tpuntoanterior
									intervalotarget = intervaloultimotono + 1
									inicio_target = Get start point: tier_tonicidad, intervaloultimotono
									fin_target = Get end point: tier_tonicidad, intervaloultimotono+1
									select Pitch 'base$'
									f0_targetanterior = Get maximum: inicio_target, fin_target, "Hertz", "Parabolic"
									if f0_targetanterior = undefined
										@undefined: f0_targetanterior, fin_target
										f0_targetanterior = value
									endif
									#select PitchTier 'base$'
									#f0_targetanterior = Get value at time: fin_target
									difconlaanterior = (12 / log10 (2)) * log10 ('f0tonmin' / 'f0_targetanterior')
									printline difconlaanterior 'difconlaanterior'
									if difconlaanterior < umbralnegativo
										etiquetatonoprofundo$ = "L*+H"
									endif
								endif
							endif
						endif
		printline fórmula prenúcleo 'labeli$' H+L*+H
					endif


					# if difpreton >= 'umbral' and diftonpos < 'umbralnegativo'
						# etiquetatono$ = "L+H*+L"
						# if f = 1
							# etiquetatonoprofundo$= "L+H*+L"
						# else
							# if abs (difpreton) >= abs (diftonpos)
								# etiquetatono$ = "L+(H*+L)"
								# etiquetatonoprofundo$= "L+H*"
								# #if diftonmintonmax > 'umbral' and a= 1
								# #	etiquetatonoprofundo$ = "L+<H*"
								# #endif
							# else
								# etiquetatono$ = "(L+H*)+L"
								# if c= 1
									# etiquetatonoprofundo$= "H*+L"
								# else
									# etiquetatonoprofundo$= "L+H*"
								# endif
							# endif
						# endif
		# printline fórmula prenúcleo 'labeli$' L+H*+L
					# endif






					##########	ESCRIBE LA ETIQUETA QUE HA SALIDO DE LAS FORMULAS	##################
					select TextGrid 'base$'
					Insert point... 'tier_Tones' 'mediotonica' 'etiquetatono$'
					if etiquetaje_profundo = 1
						Insert point... 'tier_profundo' 'mediotonica' 'etiquetatonoprofundo$'
					endif

					##############
				# acaba el if de condición de la sílaba contiene marca de tónica
				endif
			# acaba el if de si el numero de intervalo es más pequeño que el final
			endif
			#acaba bucle de todos los intervalos de IP


		endfor




		#####################	ACCIONES PARA LA ULTIMA TÓNICA 	##############
		#ahora el número de intervalo de la ultima tonica de la frase está almacenada en ultimatonica
	printline CONFIGURACIÓN NUCLEAR
		#calcula acento de la última tónica sea cual sea el tipo acentual
		if ultimatonica < 1
			pause There are not stressed syllables
		endif
		select TextGrid 'base$'
		startingpointlastton = Get start point... 'tier_tonicidad' 'ultimatonica'
		endingpointlastton = Get end point... 'tier_tonicidad' 'ultimatonica'
		ultimasilaba = endIntervalIP-1
		endingpointlastsyl = Get end point... 'tier_tonicidad' 'ultimasilaba'
		durlastton = endingpointlastton - startingpointlastton
		mediolastton = startingpointlastton + (durlastton/2)
		parteslastton=  durlastton/6
		t4lastton = parteslastton*2
		t5lastton = parteslastton*4

		# pretónica de la última tonica
		pretonlastton = ultimatonica - 1
		startingpointprelastton = Get start point... 'tier_tonicidad' 'pretonlastton'
		endingpointprelastton = Get end point... 'tier_tonicidad' 'pretonlastton'
		durprelastton = endingpointprelastton - startingpointprelastton
		medioprelastton = startingpointprelastton + (durprelastton/2)

		# postónica de la última tonica
		postonlastton = ultimatonica + 1
		startingpointposlastton = Get start point... 'tier_tonicidad' 'postonlastton'
		endingpointposlastton = Get end point... 'tier_tonicidad' 'postonlastton'
		durposlastton = endingpointposlastton - startingpointposlastton
		medioposlastton = startingpointposlastton + (durposlastton/2)
		parteslastpos=  durposlastton/6
		t4lastpos = parteslastpos*2
		t5lastpos = parteslastpos*4

		#obtencion valores F0 ultima tonica
		select PitchTier 'base$'

		f01pre = Get value at time... 'startingpointprelastton'
		f02pre = Get value at time... 'medioprelastton'
		f03pre = Get value at time... 'endingpointprelastton'



		f01ton = Get value at time... 'startingpointlastton'
		f02ton = Get value at time... 'mediolastton'
		f03ton = Get value at time... 'endingpointlastton'
		f04ton = Get value at time... 't4lastton'
		f05ton = Get value at time... 't5lastton'
		printline último tono:
		printline f0 tonica:  'f01ton' Hz, 'f02ton' Hz, 'f03ton' Hz.



		# si no hay pretonica, los valores de la pretonica son los valores de inicio de la tónica
		if numberOfIntervalPretonica = 1
			f02pre = f01ton
		endif
		
		f0fin = Get value at time... 'endingpointlastsyl'

		f01pos = Get value at time... 'startingpointposlastton'
		f02pos = Get value at time... 'medioposlastton'
		f03pos = Get value at time... 'endingpointposlastton'
		f04pos = Get value at time... 't4lastpos'
		f05pos = Get value at time... 't5lastpos'

		#elige valor más alto...
		f0maxultimatonica = max (f01ton, f02ton,f03ton,f04ton,f05ton)

		select Pitch 'base$'
		f0maxton = Get maximum: startingpointlastton, endingpointlastton, "Hertz", "Parabolic"
		if f0maxton= undefined
			@undefined: f0maxton, endingpointlastton
			f0maxton = value
		endif
			printline f02pre: 'f02pre' f02pos: 'f02pos'
		##### 	calculos semitonos ultima tonica #######
		difpreton = (12 / log10 (2)) * log10 ('f02ton' / 'f02pre')
		diftonpos = (12 / log10 (2)) * log10 ('f02pos' / 'f02ton')
		diftonton = (12 / log10 (2)) * log10 ('f03ton' / 'f02ton')
		diftonton1 = (12 / log10 (2)) * log10 ('f02ton' / 'f01ton')
		diftonton2 = (12 / log10 (2)) * log10 ('f03ton' / 'f01ton')
		difprepre = (12 / log10 (2)) * log10 ('f03pre' / 'f01pre')
		diftonfin = (12 / log10 (2)) * log10 ('f0fin' / 'f02ton')
		difpremaxton = (12 / log10 (2)) * log10 ('f0maxton' / 'f02pre')
		diftonmaxton = (12 / log10 (2)) * log10 ('f0maxton' / 'f01ton')
		printline difpreton 'difpreton'  diftonpos 'diftonpos' diftonton 'diftonton' diftonton2 'diftonton2'



		########### FORMULAS ULTIMA TÓNICA NO AGUDA	###########

		etiquetatono$ = "última-tónica-no-aguda"
		etiquetaprofunda$ = "última-tónica-no-aguda"
		printline fórmulas última tónica

		pitchaccent$ = ""


			#CALCULO DEL TONO EN VEZ DE POR TERCIOS POR DECLINACION
			select TextGrid 'base$'
			numeropuntosahora = Get number of points: 'tier_Tones'
			printline numeropuntosahora 'numeropuntosahora'
			labeltonicaanterior$ = ""
			if numeropuntosahora >=2
				tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora-1
				labeltonicaanterior$ = Get label of point: tier_Tones, numeropuntosahora-1
					select PitchTier 'base$'
					f0_puntoanterior = Get value at time: tpuntoanterior
					select TextGrid 'base$'
					intervaloptoanterior = Get interval at time: tier_tonicidad, tpuntoanterior
					iniciointervaloanterior = Get start point: tier_tonicidad, intervaloptoanterior
					fintargetanterior = Get end point: tier_tonicidad, intervaloptoanterior+1
					select Pitch 'base$'
					f0maxtargetanterior = Get maximum: iniciointervaloanterior, fintargetanterior, "Hertz", "Parabolic"
					if f0maxtargetanterior = undefined
						@undefined: f0maxtargetanterior, fintargetanterior
								f0maxtargetanterior = value
					endif
					difconlaanterior = (12 / log10 (2)) * log10 (f01ton / f0maxtargetanterior)
					printline difconlaanterior 'difconlaanterior'

				if difconlaanterior < umbralnegativo
					pitchaccent$ = "L*"
					etiquetatono$ = "L*"
					etiquetaprofunda$ = "L*"
					tonicaH =0
				endif
				if ('difconlaanterior' > 'umbralnegativo') 
					if ((labeltonicaanterior$ = "H*") or (labeltonicaanterior$ = "L*+H") or (labeltonicaanterior$ = "L+H*") or (labeltonicaanterior$ = "(L+H*)+H") or (labeltonicaanterior$ = "L+(H*+H)") or (labeltonicaanterior$ = "L*+(H+H)") or (labeltonicaanterior$ = "(L*+H)+H)") or (labeltonicaanterior$ = "(L+H*)+L)") or (labeltonicaanterior$ = "L+(H*+L)"))
						pitchaccent$ = "H*"
						etiquetatono$ = "H*"
						etiquetaprofunda$ = "H*"
						tonicaH =1
					else
						if f01ton > tercio2
							pitchaccent$ = "L*"
							etiquetatono$ = "L*"
							etiquetaprofunda$ = "L*"
							tonicaH =0
						endif
						if f01ton < tercio2
							pitchaccent$ = "L*"
							etiquetatono$ = "L*"
							etiquetaprofunda$ = "L*"
							tonicaH =0
						endif
					endif
				endif

			else
				difconlaanterior = (12 / log10 (2)) * log10 ('f02ton' / 'f02pre')
				if ('difconlaanterior' < 'umbralnegativo') and ((labeltonicaanterior$ = "H*") or (labeltonicaanterior$ = "L*+H") or (labeltonicaanterior$ = "L+H*") or (labeltonicaanterior$ = "(L+H*)+H")or (labeltonicaanterior$ = "L+(H*+H)") or (labeltonicaanterior$ = "L*+(H+H)") or (labeltonicaanterior$ = "(L*+H)+H)") or (labeltonicaanterior$ = "(L+H*)+L)"))
					pitchaccent$ = "L*"
					etiquetatono$ = "L*"
					etiquetaprofunda$ = "L*"
					tonicaH =0
				else
					if f01ton > tercio2
						pitchaccent$ = "H*"
						etiquetatono$ = "H*"
						etiquetaprofunda$ = "H*"
						tonicaH =1
					endif
					if f01ton < tercio2
						pitchaccent$ = "L*"
						etiquetatono$ = "L*"
						etiquetaprofunda$ = "L*"
						tonicaH =0
					endif
				endif
			printline pitchaccent 'pitchaccent$'
			endif

		# if abs (difpreton) < 'umbral' and f02ton < tercio2
			# etiquetatono$ = "L*"
			# etiquetaprofunda$ = "L*"
			# tonicaH = 0
			# printline L*
		# endif

		# if abs (difpreton) < 'umbral' and f02ton >= tercio2
			# etiquetatono$ = "H*"
			# etiquetaprofunda$ = "H*"
			# tonicaH = 1
			# printline H*
		# endif

		
		
		if diftonpos > umbral and pitchaccent$ = "H*"
			etiquetatono$ = "L*+H"
			etiquetaprofunda$ = "L*+H"
			tonicaH = 1
		endif
		
		
		if abs (difpreton) < 'umbral' and pitchaccent$ = "L*"
			etiquetatono$ = "L*"
			etiquetaprofunda$ = "L*"
			tonicaH = 0
			printline L*
		endif

		if abs (difpreton) < 'umbral' and pitchaccent$ = "H*"
			etiquetatono$ = "H*"
			etiquetaprofunda$ = "H*"
			tonicaH = 1
			printline H*
		endif

		# ETIQUETA PROBLEMATICA esto no existe en español (bajada en la pretónica) en teoría así que en profundo queda el pitchaccent
		if  difpreton < 'umbralnegativo'
			etiquetatono$ = "H+L*"
			tonicaH=0
			if diftonpos > umbral
				etiquetatono$ = "H+L*+H"
				if abs (difpreton) > diftonpos
					etiquetatono$ = "H+(L*+H)"
				else
					etiquetatono$ = "H+(L*+H)"
				endif
			endif
			printline Bajada en la pretónica (tónica baja), noes un tono fonológico en español
			if (!lengua = 3) and (!lengua= 2)
			etiquetaprofunda$ = "H+L*"
			printline H+L* Bajada en la pretónica (tónica baja)
			endif
		endif

		if abs (difpreton) < 'umbral' and diftonton < 'umbralnegativo'
			etiquetatono$ = "H*+L"
			etiquetaprofunda$ = "H*+L"
			tonicaH=0
			if c = 0
				etiquetaprofunda$ = "H*"
			endif
			tonicaH = 1
			printline H*+L
		endif

		# H+L* PUESTO PARA QUE DIGA DESACENTUADO SI VIENE DE OTRO TONO
		#calcula si ha habido declinación entre el último tono y la prétonica del tono actual. Si ha pasado significa que no hay un target alto en la pretónica por tanto, no es H+L*
		if diftonton2 < 'umbralnegativo'
			etiquetatono$ = "H+L*"
			etiquetaprofunda$ = "H+L*"
			tonicaH=0
			if lengua = 3 or lengua =2
				select TextGrid 'base$'
				numeropuntosahora = Get number of points: 'tier_Tones'
				if numeropuntosahora >=1
					labeltonicaanterior$ = Get label of point: tier_Tones, numeropuntosahora

					if numeropuntosahora >1
						tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora-1

						intervaloultimotono = Get interval at time: tier_tonicidad, tpuntoanterior
						labeltonoanterior$ = Get label of point: tier_Tones, numeropuntosahora-1

						if (labeltonoanterior$ = "L*+H") or (labeltonoanterior$ = "H+(L*+H)") or (labeltonoanterior$ = "(H+L*)+H") or (labeltonoanterior$ = "(L+H*)+H") or (labeltonoanterior$ = "L+(H*+H)")
							inicio_target = Get start point: tier_tonicidad, intervaloultimotono+1
							fin_target = Get end point: tier_tonicidad, intervaloultimotono+1
							select Pitch 'base$'
							target_anterior = Get maximum: inicio_target, fin_target, "Hertz", "Parabolic"
							if target_anterior = undefined
								@undefined: target_anterior, fin_target
								target_anterior = value
							endif
						else
							select Pitch 'base$'
							target_anterior = Get maximum: tpuntoanterior-0.05, tpuntoanterior+0.05, "Hertz", "Parabolic"
							if target_anterior = undefined
								@undefined: target_anterior, tpuntoanterior
								target_anterior = value
							endif
						endif
					endif

					if numeropuntosahora <= 1
						inicio_frase = Get start point: tier_tonicidad, 2
						select PitchTier 'base$'
						target_anterior = Get value at time: inicio_frase
					endif

					#aquí si pongo con el pto 3 de la pretónica deja de ver los H+L*
					difconlaanterior = (12 / log10 (2)) * log10 ('f01pre' / 'target_anterior')
					printline difconlaanterior 'difconlaanterior'


					if numeropuntosahora <= 1 and difconlaanterior < 'umbralnegativo'
						etiquetatono$ = "H+L*"
						etiquetaprofunda$ = "L*"
						tonicaH= 0
						printline H+L*
					endif

					if (numeropuntosahora > 1) and (labeltonicaanterior$ <> "H+L*") and (labeltonicaanterior$ <> "H+(L*+H)") and (difconlaanterior < 'umbralnegativo')
						etiquetatono$ = "H+L*"
						etiquetaprofunda$ = "L*"
						tonicaH=0
					endif
				endif
			endif
		printline H+L* fonético
		endif


		



		# H+L* PUESTO PARA QUE DIGA DESACENTUADO SI VIENE DE OTRO TONO
		#esta mira si el tono H que hay en la pretónica es la postónica del tono H de un tono anterior y entonces le coloca sólo la L*
		#FALTA COLOCARLE LA DECLINACION PORQUE SINO DESACENTUARÁ COSAS QUE NO TOCAN
		if diftonton2 < 'umbralnegativo'
			tonicaH = 0
			#busca si el intervalo actual -2 es una tónica (eso quiere decir que la pretónica de la tónica actual es la postónica de otro tono y si ese otro tono tiene un pico pospuesto no coloca H a la pretónica del actual)
				select TextGrid 'base$'
				numeropuntosahora = Get number of points: tier_Tones
				if numeropuntosahora >1
					#busca el último tono
					tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora-1
					intervaloultimotono = Get interval at time: tier_tonicidad, tpuntoanterior

					if intervaloultimotono = ultimatonica-2
						labeltonoanterior$ = Get label of point: tier_Tones, numeropuntosahora-1
						if (labeltonoanterior$ = "L*+H") and diftonmaxton > 'umbral'
							etiquetatono$ = "H+L*"
							etiquetaprofunda$ = "L*"
							printline H+L* --> L*
							tonicaH=0
						endif
					endif
				endif

		endif




		if (difpreton >= 'umbral') or (diftonton2 >= 'umbral') or (diftonmaxton >= umbral)
			etiquetatono$ = "L+H*"
			etiquetaprofunda$ = "L+H*"
			tonicaH = 1
			printline L+H*

			if difpreton >= umbral and diftonpos < umbralnegativo
				if abs (difpreton) > abs (diftonpos)
					etiquetatono$ = "L+(H*+L)"
					etiquetaprofunda$ = "L+H*"
				elsif difpreton <diftonpos
					etiquetatono$ = "(L+H*)+L"
					etiquetaprofunda$ = "H*+L"
				endif
			endif

			#solo aplica a los L+H* H%
			if (difpreton>= umbral or (diftonton2>=umbral)) and diftonfin >= umbral
				# si la subida en la primera mitad de la tónica no pasa el umbral... Y el tono empieza bajo, si no puede ser una suspendida
				select TextGrid 'base$'
				numberpoints = Get number of points: tier_Tones
				if pitchaccent$ = "L*" and ((diftonton1 < umbral) or (diftonton<umbral) or (diftonton2<umbral) or (f01ton > f02ton)) and (numberpoints > 1)
					etiquetatono$ = "L+H*"
					etiquetaprofunda$ = "L*"
					printline L+H*--> L*
					tonicaH = 1
				endif
			endif
		endif



		if (difpremaxton >= umbral_upstep) and ((lengua = 3) or (lengua = 2))
			etiquetatono$ = "L+\!dH*"
			etiquetaprofunda$ = "L+\!dH*"
			printline L+¡H*
			if b= 2
			etiquetaprofunda$ = "L+H*"
			endif
			tonicaH = 1
		endif



		# ¡H calculada como las extraaltas del catalan solo con que sea más alta, no tiene que pasar el umbral
		#si esta subida se cumple pero lo anterior es un plateau alto
		#COSAS RARAS PARA DOS ALINEACIONES DE TONO Y PARA LAS ¡H QUE SON ¡ PORQUE SON MÁS ALTAS QUE UNA H ANTERIOR
		# las de como si no pasan el umblral se quedan sobre 1.2St
		if 	(difpreton>= 'umbral') and ((diftonton < 'umbralnegativo') or (diftonpos < 'umbralnegativo')) and (abs (difpreton) < abs (diftonpos))
			etiquetatono$ = "(L+H*)+L"
			etiquetaprofunda$ = "H*+L"
			printline H*+L
			tonicaH=0
			if c = 0
				etiquetaprofunda$ = "L+H*"
			endif

			if lengua= 2 or lengua= 3 and difpremaxton >= 'umbral_upstep'
				etiquetatono$ = "(L+\!dH*)+L"
				etiquetaprofunda$ = "L+\!dH*"
				if b= 2
				etiquetaprofunda$ = "L+H*"
				endif
			endif

			select TextGrid 'base$'
			numeropuntosahora = Get number of points: 'tier_Tones'
			printline numeropuntosahora 'numeropuntosahora'
			if numeropuntosahora >=2
				labeltonicaanterior$ = Get label of point: tier_Tones, numeropuntosahora-1
				tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora-1
					select PitchTier 'base$'
					f0_puntoanterior = Get value at time: tpuntoanterior
					difconlaanterior = (12 / log10 (2)) * log10 ('f01pre' / 'f0_puntoanterior')
					printline difconlaanterior 'difconlaanterior'

				if  lengua = 2 and ('difconlaanterior' > 'umbralnegativo') and ((labeltonicaanterior$ = "H*") or (labeltonicaanterior$ = "L*+H") or (labeltonicaanterior$ = "L+H*") or (labeltonicaanterior$ = "(L+H*)+H")or (labeltonicaanterior$ = "L+(H*+H)") or (labeltonicaanterior$ = "L*+(H+H)")or (labeltonicaanterior$ = "(L*+H)+H)") or (labeltonicaanterior$ = "(L+H*)+L)"))
					etiquetatono$ = "\!dH*"
					etiquetaprofunda$= "\!dH*"
					printline ¡H* (como si Sevilla, preg Canarias etc.)

				else

					printline L+H* (prueba para cuando es L+\!dH* por los 6 st)
					if difpremaxton >= umbral_upstep
						etiquetatono$ = "L+\!dH*"
						etiquetaprofunda$= "L+\!dH*"
						if b= 2
							etiquetaprofunda$ = "L+H*"
						endif
						printline L+\!dH para las preg parciales del catalán
					endif
				endif
			endif
			tonicaH = 0
		endif


		######## escribe etiqueta de la última tónica ##########
		select TextGrid 'base$'
		numberOfPoints = Get number of points... 'tier_Tones'
		if numberOfPoints < 1
			exit No hay ninguna tónica analizada
		endif
		Remove point... 'tier_Tones' 'numberOfPoints'
		Insert point... 'tier_Tones' 'mediolastton' 'etiquetatono$'
		if etiquetaje_profundo = 1
			Remove point... 'tier_profundo' 'numberOfPoints'
			Insert point... 'tier_profundo' 'mediolastton' 'etiquetaprofunda$'
		endif


		#######################			TONOS JUNTURA			#######################

		ultimasilaba = endIntervalIP




		select TextGrid 'base$'
		endingpointlastsyl = Get end point... 'tier_tonicidad' 'ultimasilaba'
		tipoacentual = ultimasilaba - ultimatonica
		#dice si es aguda
		if tipoacentual = 0
		printline tipoacentual 'tipoacentual'

			select TextGrid 'base$'
			endpointcola = endingpointlastsyl
			startingpointcola = startingpointlastton
			durcola = endpointcola - startingpointcola
			partes = durcola/12
			t0cola = startingpointcola
			t3cola = startingpointcola + (3*partes)
			t4cola = startingpointcola + (4*partes)
			t6cola = startingpointcola + (6*partes)
			t8cola = startingpointcola + (8*partes)
			t9cola = startingpointcola + (9*partes)
			t12cola = startingpointcola + (12*partes)

			select PitchTier 'base$'
			f00cola = Get value at time... 't0cola'
			f03cola = Get value at time... 't3cola'
			f04cola = Get value at time... 't4cola'
			f06cola = Get value at time... 't6cola'
			f08cola = Get value at time... 't8cola'
			f09cola = Get value at time... 't9cola'
			f012cola = Get value at time... 't12cola'






			select TextGrid 'base$'
			pointultimatonica = Get number of points... 'tier_Tones'

			##### Formulas para calcular tonos de frontera monotonales
			dif126 = (12 / log10 (2)) * log10 ('f012cola' / 'f06cola')
			difpre3 = (12 / log10 (2)) * log10 ('f03cola' / 'f02pre')
			difpre6 = (12 / log10 (2)) * log10 ('f06cola' / 'f02pre')
			dif96 = (12 / log10 (2)) * log10 ('f09cola' / 'f06cola')
			dif129 = (12 / log10 (2)) * log10 ('f012cola' / 'f09cola')
			dif63 = (12 / log10 (2)) * log10 ('f06cola' / 'f03cola')
			dif12max = (12 / log10 (2)) * log10 ('f012cola' / 'f0maxultimatonica')
			

			#pone un punto vacío para tener que borrar los dos últimos puntos en todos los casos
			Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
			if etiquetaje_profundo = 1
				Insert point... 'tier_profundo' 't12cola' 'etiquetafinalprofunda$'
			endif
			pointfinal = Get number of points... 'tier_Tones'

			#####	FORMULAS para las agudas	#######
			etiquetafinal$ = "final-aguda"
			etiquetafinalprofunda$ = "final-aguda"

			##########	monotonales después de L
			if tonicaH = 0 and dif126 < 'umbral'
				etiquetafinal$ = "L\% "
				etiquetafinalprofunda$ = "L\% "
				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'tier_profundo' 'pointfinal'
					Insert point... 'tier_profundo' 't12cola' 'etiquetafinalprofunda$'
				endif
				printline etiqueta final L%
			endif

			if tonicaH = 0 and dif126 >= 'umbral'
				etiquetafinal$ = "H\% "
				etiquetafinalprofunda$ = "H\% "
				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'tier_profundo' 'pointfinal'
					Insert point... 'tier_profundo' 't12cola' 'etiquetafinalprofunda$'
				endif
				printline etiqueta final H%
			endif

			#formulacalculomid
			if tonicaH = 0 and dif126 >= 'umbral' and f012cola <= tercio2
				etiquetafinal$ = "!H\% "
				etiquetafinalprofunda$ = "!H\% "

				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'tier_profundo' 'pointfinal'
					Insert point... 'tier_profundo' 't12cola' 'etiquetafinalprofunda$'
				endif
				printline etiqueta final !H%
			endif


			#monotonales después de H
			if tonicaH = 1 and dif126 >= 'umbralnegativo'
				etiquetafinal$ = "H\% "
				etiquetafinalprofunda$ = "H\% "

				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'tier_profundo' 'pointfinal'
					Insert point... 'tier_profundo' 't12cola' 'etiquetafinalprofunda$'
				endif
				printline etiqueta final H%
			endif




			if tonicaH = 1 and dif126 < 'umbralnegativo'
				etiquetafinal$ = "L\% "
				etiquetafinalprofunda$ = "L\% "

				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'tier_profundo' 'pointfinal'
					Insert point... 'tier_profundo' 't12cola' 'etiquetafinalprofunda$'
				endif
			endif

			if tonicaH = 1  and (f012cola > tercio1) and ((dif126 < 'umbralnegativo') or (dif12max<'umbralnegativo'))
				etiquetafinal$ = "!H\% "
				etiquetafinalprofunda$ = "!H\% "
				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'tier_profundo' 'pointfinal'
					Insert point... 'tier_profundo' 't12cola' 'etiquetafinalprofunda$'
				endif
				printline etiqueta final !H%
			endif

			if tonicaH = 1  and (f012cola > tercio1) and (dif12max<1) and durcola>0.60
				etiquetafinal$ = "!H\% "
				etiquetafinalprofunda$ = "!H\% "
				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'tier_profundo' 'pointfinal'
					Insert point... 'tier_profundo' 't12cola' 'etiquetafinalprofunda$'
				endif
				printline etiqueta final !H%
			endif


			########## BITONALES
			etiquetatono$= "ultima-tonica-aguda"
			etiquetatonoprofundo$= "ultima-tonica-aguda"
			etiquetafinal$ = "tonema-agudo"
			pitchaccent$ = ""

			#CALCULO DEL TONO EN VEZ DE POR TERCIOS POR DECLINACION
			select TextGrid 'base$'
			numeropuntosahora = Get number of points: 'tier_Tones'
			printline numeropuntosahora 'numeropuntosahora'
			if numeropuntosahora >=3
				labeltonicaanterior$ = Get label of point: tier_Tones, numeropuntosahora-1
				tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora-1
					select PitchTier 'base$'
					f0_puntoanterior = Get value at time: tpuntoanterior
					select TextGrid 'base$'
					intervaloptoanterior = Get interval at time: tier_tonicidad, tpuntoanterior
					iniciointervaloanterior = Get start point: tier_tonicidad, intervaloptoanterior
					fintargetanterior = Get end point: tier_tonicidad, intervaloptoanterior+1
					select Pitch 'base$'
					f0maxtonicaanterior = Get maximum: iniciointervaloanterior, fintargetanterior, "Hertz", "Parabolic"
					if f0maxtonicaanterior = undefined
						@undefined: f0maxtonicaanterior, fintargetanterior
								f0maxtonicaanterior = value
					endif
					difconlaanterior = (12 / log10 (2)) * log10 (f01ton / f0maxtonicaanterior)
					printline difconlaanterior 'difconlaanterior'

				if ('difconlaanterior' > 'umbralnegativo') and ((labeltonicaanterior$ = "H*") or (labeltonicaanterior$ = "L*+H") or (labeltonicaanterior$ = "L+H*") or (labeltonicaanterior$ = "(L+H*)+H")or (labeltonicaanterior$ = "L+(H*+H)") or (labeltonicaanterior$ = "L*+(H+H)") or (labeltonicaanterior$ = "(L*+H)+H)") or (labeltonicaanterior$ = "(L+H*)+L)"))
					pitchaccent$ = "H*"
				else
					pitchaccent$ = "L*"
				endif

			else
				difconlaanterior = (12 / log10 (2)) * log10 ('f02ton' / 'f02pre')

				if ('difconlaanterior' < 'umbralnegativo') and ((labeltonicaanterior$ = "H*") or (labeltonicaanterior$ = "L*+H") or (labeltonicaanterior$ = "L+H*") or (labeltonicaanterior$ = "(L+H*)+H")or (labeltonicaanterior$ = "L+(H*+H)") or (labeltonicaanterior$ = "L*+(H+H)") or (labeltonicaanterior$ = "(L*+H)+H)") or (labeltonicaanterior$ = "(L+H*)+L)"))
					pitchaccent$ = "L*"
				else

					if f01ton > tercio2
						pitchaccent$ = "H*"
					endif
					if f01ton < tercio2
						pitchaccent$ = "L*"
					endif
				endif
			printline pitchaccent 'pitchaccent$'
			endif


			######################	FIN CALCULO DE TONO POR DECLINACION ############################

			##### 	monotonales que tienen que tener una alineacion diferente para las agudas.

			if (difpre6 < 'umbralnegativo') and (dif126 < 'umbral')
				if difconlaanterior > 'umbralnegativo'
					etiquetatono$ = "H+L*"
					etiquetatonoprofundo$ = "H+L*"
					etiquetafinal$ = "L\% "
					etiquetafinalprofunda$= "L\% "
					@ponetiqueta ()
				else
					etiquetatono$ = "H+L*"
					etiquetatonoprofundo$ = "L*"
					etiquetafinal$ = "L\% "
					etiquetafinalprofunda$= "L\% "
					@ponetiqueta ()

					printline formula monotonales-agudasalineacionespecial H* L%--> L*L%
				endif
			endif

			if pitchaccent$ = "H*" and ((abs (difpre3)) < 'umbral') and dif126 < 'umbralnegativo'
				etiquetatono$ = "H*"
				etiquetatonoprofundo$ = "H*"
				etiquetafinal$ = "L\% "
				etiquetafinalprofunda$= "L\% "
				@ponetiqueta ()
				printline formula monotonales-agudasalineacionespecial H* L%
			endif





			################################################


			if pitchaccent$ = "L*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral') )
				... and (dif96 >= 'umbral' and dif129 < 'umbralnegativo')
				etiquetatono$ = "L*"
				etiquetatonoprofundo$ = "L*"
				etiquetafinal$ = "HL\% "
				etiquetafinalprofunda$= "HL\% "
				@ponetiqueta ()
				printline formula 1 L* HL%
			endif


			if pitchaccent$ = "L*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif96 >= 0.50 and dif129 < -0.50) and durcola > 0.50
				etiquetatono$ = "L*"
				etiquetatonoprofundo$ = "L*"
				etiquetafinal$ = "L\% "
				etiquetafinalprofunda$= "HL\% "
				@ponetiqueta ()
				printline formula 1 L* HL%
				printline difpre3 'difpre3' dif96 'dif96' dif129 'dif912'
			endif




			#######PRUEBA
			#duplicados de las de arriba para una alineación tonal diferente
			if pitchaccent$ = "L*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif63 >= 'umbral' and dif126 < 'umbralnegativo')
				etiquetatono$ = "L*"
				etiquetatonoprofundo$ = "L*"
				etiquetafinal$ = "HL\% "
				etiquetafinalprofunda$= "HL\% "
				@ponetiqueta ()
				printline 2 L* HL % con otra alineación
			endif
			##### fin duplicado


			if pitchaccent$ = "L*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and ((dif96 < 'umbral' or dif96 >= 'umbralnegativo') and (dif129 >= 'umbral'))
				etiquetatono$ = "L*"
				etiquetafinal$ = "LH\% "
				etiquetatonoprofundo$ = "L*"
				etiquetafinalprofunda$ = "LH\% "
				if d=2
				etiquetafinalprofunda$ = "H\% "
				endif
				@ponetiqueta ()
				printline 3 L* LH%
			endif



			if pitchaccent$ = "L*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and ((dif96 >= 'umbral') and (dif129 < 'umbralnegativo') and (f012cola > tercio1))
				etiquetatono$ = "L*"
				etiquetafinal$ = "H!H\% "
				etiquetatonoprofundo$ = "L*"
				etiquetafinalprofunda$ = "H!H\% "
				@ponetiqueta ()
				printline 5 L* H!H%
			endif

			if  pitchaccent$ = "L*" and difconlaanterior > 'umbralnegativo' and difpre3 < 'umbralnegativo'
				... and dif96 >= 'umbral' and dif129 < 'umbralnegativo'
				etiquetatono$ = "H+L*"
				etiquetafinal$ = "HL\% "
				etiquetatonoprofundo$ = "H+L*"
				etiquetafinalprofunda$ = "HL\% "

				@ponetiqueta ()
				printline 6 H+L* HL%

			endif


			if  pitchaccent$ = "L*" and difconlaanterior > 'umbralnegativo' and difpre3 < 'umbralnegativo'
				... and dif63 > 0.50 and dif129 < -0.50 and durcola > 0.50
				etiquetatono$ = "H+L*"
				etiquetafinal$ = "L\% "
				etiquetatonoprofundo$ = "H+L*"
				etiquetafinalprofunda$ = "HL\% "

				@ponetiqueta ()
				printline 6 H+L* HL%
			endif



			if  pitchaccent$ = "L*" and difconlaanterior > 'umbralnegativo' and difpre3 < 'umbralnegativo'
				... and (dif96 < 'umbral' or dif96 >= 'umbralnegativo') and dif129 >= 'umbral'
				etiquetatono$ = "H+L*"
				etiquetafinal$ = "LH\% "
				etiquetatonoprofundo$ = "H+L*"
				etiquetafinalprofunda$ = "LH\% "
				if d=2
					etiquetafinalprofunda$ = "H\% "
				endif
				@ponetiqueta ()
	printline 7 H+L* LH%
			endif

			if  pitchaccent$ = "L*" and difconlaanterior > 'umbralnegativo' and difpre3 < 'umbralnegativo'
				... and (dif96 < 'umbral' or dif96 >= 'umbralnegativo') and dif129 >= 'umbral' and f012cola < tercio2
				etiquetatono$ = "H+L*"
				etiquetafinal$ = "L!H\% "
				etiquetatonoprofundo$ = "H+L*"
				etiquetafinalprofunda$ = "L!H\% "

				@ponetiqueta ()
	printline 8 H+L* L!H%
			endif

			if   pitchaccent$ = "L*" and difconlaanterior > 'umbralnegativo' and difpre3 < 'umbralnegativo'
				... and dif96 >= 'umbral' and dif129 < 'umbralnegativo' and f012cola > tercio1
				etiquetatono$ = "H+L*"
				etiquetafinal$ = "H!H\% "
				etiquetatonoprofundo$ = "H+L*"
				etiquetafinalprofunda$ = "H!H\% "
				@ponetiqueta ()
	printline 9  H+L* H!H%
			endif

			# después de h*
			if pitchaccent$= "H*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif96 >= 'umbralnegativo' and dif96 < 'umbral' and dif129 < 'umbralnegativo')
				etiquetatono$ = "H*"
				etiquetafinal$ = "HL\% "
				etiquetatonoprofundo$ = "H*"
				etiquetafinalprofunda$ = "HL\% "

				@ponetiqueta ()
	printline 10 H* HL%
			endif

			if pitchaccent$= "H*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif96 < 'umbralnegativo' and dif129 > 'umbral')
				etiquetatono$ = "H*"
				etiquetafinal$ = "LH\% "
				etiquetatonoprofundo$ = "H*"
				etiquetafinalprofunda$ = "LH\% "
				@ponetiqueta ()
	printline 11 H* LH%

			endif

			if pitchaccent$= "H*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif96 < 'umbralnegativo' and dif129 > 'umbral' and f012cola < tercio2)
				etiquetatono$ = "H*"
				etiquetafinal$ = "L!H\% "
				etiquetatonoprofundo$ = "H*"
				etiquetafinalprofunda$ = "L!H\% "

				@ponetiqueta ()
	printline 12 H* L!H%
			endif

			if pitchaccent$= "H*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif96 >= 'umbralnegativo' and dif96 < 'umbral' and dif129 < 'umbralnegativo' and f012cola >= tercio1)
				etiquetatono$ = "H*"
				etiquetafinal$ = "H!H\% "
				etiquetatonoprofundo$ = "H*"
				etiquetafinalprofunda$ = "H!H\% "

				@ponetiqueta ()
	printline 13 H* H!H%
			endif

			if pitchaccent$= "H*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif96 >= 'umbral' and dif129 < 'umbralnegativo')
				etiquetatono$ = "H*"
				etiquetafinal$ = "\!dHL\% "
				etiquetatonoprofundo$ = "H*"
				etiquetafinalprofunda$ = "\!dHL\% "

				@ponetiqueta ()
	printline 14 H*\!dHL%
			endif

			if pitchaccent$= "H*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and ((dif96 >= 'umbral') and (dif129 < 'umbralnegativo') and (f012cola >= tercio1))
				etiquetatono$ = "H*"
				etiquetafinal$ = "\!dH!H\% "
				etiquetatonoprofundo$ = "H*"
				etiquetafinalprofunda$ = "\!dH!H\% "

				@ponetiqueta ()
	printline 15 H* \!dH!H%
			endif

			if difpre3 >= 'umbral'
				... and dif96 >= 'umbralnegativo' and dif96 < 'umbral' and dif129 < 'umbralnegativo'
				etiquetatono$ = "L+H*"
				etiquetafinal$ = "HL\% "
				etiquetatonoprofundo$ = "L+H*"
				etiquetafinalprofunda$ = "HL\% "
				@ponetiqueta ()
			endif

			if (difpre3 >= 'umbral' or difpre6 >= 'umbral') and (dif96 < 'umbralnegativo' or dif96 < 'umbral') and dif129 > 'umbral'
				etiquetatono$ = "L+H*"
				etiquetafinal$ = "LH\% "
				etiquetatonoprofundo$ = "L+H*"
				etiquetafinalprofunda$ = "LH\% "
	printline 16 L+H* LH%
				@ponetiqueta ()
			endif

			if difpre3 >= umbral and dif96 < -1 and dif129 > 1 and durcola> 0.5
				etiquetatono$ = "L+H*"
				etiquetafinal$ = "H\% "
				etiquetatonoprofundo$ = "L+H*"
				etiquetafinalprofunda$ = "LH\% "
	printline 16 L+H* LH%
				@ponetiqueta ()
			endif



			if difpre3 >= 'umbral' and dif96 < 'umbralnegativo' and dif129 > 'umbral' and f012cola < tercio2
				etiquetatono$ = "L+H*"
				etiquetafinal$ = "L!H\% "
				etiquetatonoprofundo$ = "L+H*"
				etiquetafinalprofunda$ = "L!H\% "

				@ponetiqueta ()
			endif

			if difpre3 >= 'umbral'
				... and dif96 >= 'umbralnegativo' and dif96 < 'umbral' and dif129 < 'umbralnegativo' and f012cola >= tercio1
				etiquetatono$ = "L+H*"
				etiquetafinal$ = "H!H\% "
				etiquetatonoprofundo$ = "L+H*"
				etiquetafinalprofunda$ = "H!H\% "

				@ponetiqueta ()
			endif

			if difpre3 >= 'umbral'
				... and dif96 >= 'umbral' and dif129 < 'umbralnegativo'
				etiquetatono$ = "L+H*"
				etiquetafinal$ = "\!dHL\% "
				etiquetatonoprofundo$ = "L+H*"
				etiquetafinalprofunda$ = "\!dHL\% "
				@ponetiqueta ()
			endif

			if difpre3 >= 'umbral'
				... and dif96 >= 'umbral' and dif129 < 'umbralnegativo' and f012cola >= tercio1
				etiquetatono$ = "L+H*"
				etiquetafinal$ = "\!dH!H\% "
				etiquetatonoprofundo$ = "L+H*"
				etiquetafinalprofunda$ = "\!dH!H\% "

				@ponetiqueta ()
			endif

			if difpre3 >= 'umbral' and dif63 < 'umbralnegativo' and dif96 >= 'umbral' and dif129 < 'umbralnegativo'
				etiquetatono$ = "L+H*"
				etiquetafinal$ = "LHL\% "
				etiquetatonoprofundo$ = "L+H*"
				etiquetafinalprofunda$ = "LHL\% "

				@ponetiqueta ()
			endif

			#tritonal (pitch accent) argentina
			if e= 1 and pitchaccent$ = "L*" and difpre3 > umbral and dif63< umbralnegativo and abs (dif126)< umbral
				etiquetatono$ = "L+H*+L"
				etiquetafinal$ = "L\% "
				etiquetatonoprofundo$ = "L+H*+L"
				etiquetafinalprofunda$ = "L\% "
			endif

		#acaba cond tonema agudo
		endif

		####	condicion si el tonema no es agudo	###################
		if tipoacentual > 0
			select TextGrid 'base$'
			endpointcola = endingpointlastsyl
			startpointcola = endingpointlastton
			durcola = endpointcola - startpointcola
			partespos = durcola/6
			t0cola = startpointcola
			t2cola = startpointcola+ (2*partespos)
			t3cola = startpointcola+ (3*partespos)
			t4cola = startpointcola+ (4*partespos)
			t6cola = startpointcola+ (6*partespos)

			select PitchTier 'base$'
			f00cola = Get value at time... 't0cola'
			f02cola = Get value at time... 't2cola'
			f03cola = Get value at time... 't3cola'
			f04cola = Get value at time... 't4cola'
			f06cola = Get value at time... 't6cola'
			select Pitch 'base$'
			f0maxprimeramitaddecola = Get maximum: f00cola, f03cola, "Hertz", "Parabolic"
			if f0maxprimeramitaddecola = undefined
				f0maxprimeramitaddecola = f03cola
			endif

			f0minprimeramitaddecola = Get minimum: f00cola, f03cola, "Hertz", "Parabolic"
			if f0minprimeramitaddecola = undefined
				f0minprimeramitaddecola = f03cola
			endif


			##########	formulas para llanas y esdrujulas ##########
			#esto cambiado y no desde el centro sino desde el inicio de cola hasta final cola
			diftonfin = (12 / log10 (2)) * log10 ('f06cola' / 'f03ton')
			dif03 = (12 / log10 (2)) * log10 ('f03cola' / 'f00cola')
			dif36 = (12 / log10 (2)) * log10 ('f06cola' / 'f03cola')
			#sólo para el tritonal
			dif02 = (12 / log10 (2)) * log10 ('f02cola' / 'f00cola')
			dif34 = (12 / log10 (2)) * log10 ('f04cola' / 'f03cola')
			dif23 = (12 / log10 (2)) * log10 ('f03cola' / 'f02cola')
			dif46 = (12 / log10 (2)) * log10 ('f06cola' / 'f04cola')
			#para el mid
			dif6max = (12 / log10 (2)) * log10 ('f06cola' / 'f0maxultimatonica')
			dif0max3 = (12 / log10 (2)) * log10 ('f0maxprimeramitaddecola' / 'f00cola')
			dif0min3 = (12 / log10 (2)) * log10 ('f0minprimeramitaddecola' / 'f00cola')
			dif6min3 = (12 / log10 (2)) * log10 ('f06cola' / 'f0minprimeramitaddecola')

			printline diftonfin 'diftonfin'
			printline dif03 (final tónica- centro cola) 'dif03' dif36 (centro-final) 'dif36' dif6max 'dif6max' dif0max3 'dif0max3'

			
			etiquetafinal$= "final-no-agudo"
			etiquetafinalprofunda$="final-no-agudo"
			##########	monotonales después de L

			if (tonicaH = 0) and (diftonfin<'umbral')
				etiquetafinal$ = "L\% "
				etiquetafinalprofunda$ = "L\% "
				select TextGrid 'base$'
				labeltonicaanterior$ = Get label of point: tier_Tones, numeropuntosahora
				if labeltonicaanterior$ = "(H+L*)+H" or labeltonicaanterior$ = "H+(L*+H)"
					etiquetafinal$ = "HL\% "
					etiquetafinalprofunda$ = "HL\% "
				endif
			endif
			
			if tonicaH = 0 and diftonfin >= 'umbral'
				etiquetafinal$ = "H\% "
				etiquetafinalprofunda$ = "H\% "
			endif

			#formulacalculomid
			if tonicaH = 0 and diftonfin >= 'umbral' and f06cola <= tercio2
				etiquetafinal$ = "!H\% "
				etiquetafinalprofunda$ = "!H\% "
				select TextGrid 'base$'
				labeltonicaanterior$ = Get label of point: tier_Tones, numeropuntosahora
				if labeltonicaanterior$ = "(H+L*)+H" or labeltonicaanterior$ = "H+(L*+H)"
					etiquetafinal$ = "H!H\% "
					etiquetafinalprofunda$ = "H!H\% "
				endif
			endif


			#monotonales después de H
			if tonicaH = 1 and (diftonfin >= 'umbralnegativo')
				etiquetafinal$ = "H\% "
				etiquetafinalprofunda$ = "H\% "
				
			endif
			if tonicaH = 1 and diftonfin < 'umbralnegativo'
				etiquetafinal$ = "L\% "
				etiquetafinalprofunda$ = "L\% "
			endif
			
			if tonicaH = 1 and ((diftonfin < 'umbralnegativo')  or (dif6max<'umbralnegativo')) and f06cola > tercio1
				etiquetafinal$ = "!H\% "
				etiquetafinalprofunda$ = "!H\% "
			endif

			#mid para el vocativo añade que sea solo para el vocativo y no para truncadas y para las 
			# truncadas (mirando que de centro cola a final cola haya un descenso haz que sea en profundo L% aunque sea L pequelita como en Dorta 2013: 77)
			if tonicaH = 1 and (dif6max<umbral) and (f06cola > tercio1) and durcola > 0.5
				etiquetafinal$ = "!H\% "
				etiquetafinalprofunda$ = "!H\% "
			endif

			######### BITONALES

			# bitonales después de L

			# subida en la 1postonica y bajada en la segunda
			# en la postónica hay una subida (la diferencia es positiva), del inicio al máximo de la cola pasa el umbral. Y el final pasa el umbral negativo.
			#debería calcularla con el maximo de la cola y no el máximo de la tónica, así funcionaría también en los H+L* 
			if tonicaH = 0 and dif03 > 0 and dif0max3 >= 'umbral' and dif36 < 'umbralnegativo'
				etiquetafinal$ = "HL\% "
				etiquetafinalprofunda$ = "HL\% "
			endif

			# #duplicadas la fórmula de HL normal y la que implementa la duración cuanod no pasa el umbral
			# if tonicaH = 0 and dif03 >= 'umbral' and dif36 < 'umbralnegativo'
				# etiquetafinal$ = "HL\% "
				# etiquetafinalprofunda$ = "HL\%"
			# endif
			# if tonicaH = 0 and dif03 > 1 and dif36 < -1 and durcola >0.26
				# etiquetafinal$ = "L\% "
				# etiquetafinalprofunda$ = "HL\% "
			# endif


			# ultima tónica baja primera pos sube menos del umbral o baja más del umbral y la segunda sube
			if tonicaH = 0 and ((abs (dif03) < 'umbral') or (dif03 <= 'umbralnegativo')) and dif36 >= 'umbral'
				etiquetafinal$ = "LH\% "
				etiquetafinalprofunda$ = "LH\% "
			endif

			if tonicaH = 0 and ((abs (dif03) < 'umbral') or (dif03 <= 'umbralnegativo')) and dif36 >= 'umbral' and f06cola < 'tercio2'
				etiquetafinal$ = "L!H\% "
				etiquetafinalprofunda$ = "L!H\% "
			endif

			if tonicaH = 0 and dif03 > 'umbral' and dif36 < 'umbralnegativo' and f06cola > tercio1
				etiquetafinal$ = "H!H\% "
				etiquetafinalprofunda$ = "H!H\% "
			endif

			# bitonales después de H

			#
			if tonicaH = 1 and abs (dif03) < 'umbral' and 'dif36' < 'umbralnegativo'
				etiquetafinal$ = "HL\% "
				etiquetafinalprofunda$ = "HL\% "
			endif
			


			if tonicaH = 1 and abs (dif03) < 'umbral' and 'dif36' < 'umbralnegativo' and 'f06cola' > tercio1
				etiquetafinal$ = "H!H\% "
				etiquetafinalprofunda$ = "H!H\% "
			endif

			if tonicaH = 1 and dif03 >= 'umbral' and dif36 < 'umbralnegativo'
				etiquetafinal$ = "\!dHL\% "
				etiquetafinalprofunda$ = "HL\% "
			endif
			
			#fórmula nueva: no se si irá bien con los umbrales y eso
			if tonicaH = 1 and dif0max3 >= 'umbral' and dif36 < 'umbralnegativo'
				etiquetafinal$ = "\!dHL\% "
				etiquetafinalprofunda$ = "HL\% "
			endif

			if tonicaH = 1 and 'dif03' >= 'umbral' and 'dif36' < 'umbralnegativo' and 'f06cola' > tercio1
				etiquetafinal$ = "\!dH!H\% "
				etiquetafinalprofunda$ = "H!H\% "
			endif


			if tonicaH = 1 and 'dif03' < 'umbralnegativo' and 'dif36' >= 'umbral'
				etiquetafinal$ = "LH\% "
				etiquetafinalprofunda$ = "LH\% "
			endif
			
			#alineación para cuando hay coda s, busca la subida muy pronto confunde con los HL que tienen el pico en el punto 4.
			# if tonicaH = 1 and 'dif02' < 'umbralnegativo' and 'dif34' >= 'umbral'
				# etiquetafinal$ = "LH\% "
				# etiquetafinalprofunda$ = "LH\% "
			# endif

			



			if tonicaH = 1 and 'dif03' < 'umbralnegativo' and 'dif36' >= 'umbral' and f06cola < tercio2
				etiquetafinal$ = "L!H\% "
				etiquetafinalprofunda$ = "L!H\% "
			endif

			##########	TRITONAL		##########
			if (tonicaH = 1 and (dif02 < 'umbralnegativo' or dif03 < 'umbralnegativo')) and (((dif34 >= 'umbral') or (dif23 >= 'umbral')) and ((dif46 < 'umbralnegativo') or (dif36 < 'umbralnegativo')))
				etiquetafinal$ = "LHL\% "
				etiquetafinalprofunda$ = "LHL\% "
			endif

			##########	#######	escribe la etiqueta
			select TextGrid 'base$'
			Insert point... 'tier_Tones' 'endingpointlastsyl' 'etiquetafinal$'
			if etiquetaje_profundo = 1
				Insert point... 'tier_profundo' 'endpointcola' 'etiquetafinalprofunda$'
			endif

			#acaba condicion de agudas o el resto
		endif
		# guardo para la proxima vez que pase que el inicio de la IP tiene que ser el final de la que acaba de pasar
		startIntervalIP = endIntervalIP
	endfor #acaba el bucle para las IP 


	############## BREAK INDEX 3	##############

	if bI = 1
		etiquetafinal$ = " \O| "
		select TextGrid 'base$'
		numberOfPoints = Get number of points... tier_BI
		
		for i to numberOfPoints
			labeli = Get label of point... tier_BI i
			if labeli = 3
				timePoint = Get time of point... tier_BI i
				posbreak = Get interval at time... tier_tonicidad timePoint
				prebreak = posbreak - 1
				if posbreak > 4
					preprebreak = posbreak - 2
				else
					preprebreak = posbreak - 1
				endif
				if posbreak > 5
					prepreprebreak = posbreak - 3
				elsif posbreak > 4
					prepreprebreak = posbreak - 2
				else
					prepreprebreak = posbreak - 1
				endif

				startingtimeposbreak = Get start point... tier_tonicidad 'posbreak'
				endingtimeposbreak = Get end point... 'tier_tonicidad' 'posbreak'
				startingtimeprebreak = Get start point... tier_tonicidad 'prebreak'
				endingtimeprebreak = Get end point... 'tier_tonicidad' 'prebreak'

				select Pitch 'base$'
				f01posbreak = Get value at time: startingtimeposbreak, "Hertz", "Linear"
				if f01posbreak=undefined
					@undefined: f01posbreak, startingtimeposbreak
					f01posbreak = value
				endif
				f03posbreak = Get value at time: endingtimeposbreak, "Hertz", "Linear"
				if f03posbreak=undefined
					@undefined: f03posbreak, endingtimeposbreak
					f03posbreak=value
				endif
				f01prebreak = Get value at time: startingtimeprebreak, "Hertz", "Linear"
				if f01prebreak= undefined
					@undefined: f01prebreak, startingtimeprebreak
					f01prebreak= value
				endif
				#calcula tono de frontera L-
				if f01prebreak >= f01posbreak and f03posbreak >= f01posbreak
					etiquetafinal$ = "L-"
				endif

				#calcula tono de frontera H-

				#comprobación lugar de tónica
				select TextGrid 'base$'
				label$ = Get label of interval... 'tier_tonicidad' 'prebreak'
				for letra from 1 to numberOfLetras
					labeltext$[letra] = mid$ ("'label$'", letra)
				endfor
				#si es aguda
				if labeltext$[1] = marca_de_tonica$
					tonica = prebreak
					startingtimetonica = Get start point... 'tier_tonicidad' 'tonica'
					endingtimetonica = Get end point... 'tier_tonicidad' 'tonica'
					durtonica = endingtimetonica - startingtimetonica
					mediotonica = startingtimetonica + (durtonica/2)

					select PitchTier 'base$'

					f01tonica = Get value at time... 'startingtimetonica'
 					f02tonica = Get value at time... 'mediotonica'
					f03tonica = Get value at time... 'endingtimetonica'
					diftonbreak = (12 / log10 (2)) * log10 ('f03tonica' / 'f01tonica')

					if diftonbreak >= 'umbral' and f03tonica > f02tonica and f01posbreak > f03posbreak
						etiquetafinal$ = "H-"
					endif

				endif

				#comprobación lugar de llana
				select TextGrid 'base$'
				label$ = Get label of interval: tier_tonicidad, preprebreak

				for letra from 1 to numberOfLetras
					labeltext$[letra] = mid$ ("'label$'", letra)
				endfor
				#si es llana
				if labeltext$[1] = marca_de_tonica$
					tonica = preprebreak
					startingtimetonica = Get start point... 'tier_tonicidad' 'tonica'
					endingtimetonica = Get end point... 'tier_tonicidad' 'tonica'
					durtonica = endingtimetonica - startingtimetonica
					mediotonica = startingtimetonica + (durtonica/2)

					select PitchTier 'base$'

					f01tonica = Get value at time... 'startingtimetonica'
 					f02tonica = Get value at time... 'mediotonica'
					f03tonica = Get value at time... 'endingtimetonica'

					diftonbreak = (12 / log10 (2)) * log10 ('f01posbreak' / 'f02tonica')

					if diftonbreak >= 'umbral' and f01posbreak > f03tonica and f01posbreak > f03posbreak
						etiquetafinal$ = "H-"
					endif


				endif

				#comprobación lugar de esdrújula
				select TextGrid 'base$'
				label$ = Get label of interval... 'tier_tonicidad' 'prepreprebreak'
				for letra from 1 to numberOfLetras
					labeltext$[letra] = mid$ ("'label$'", letra)
				endfor
				#si es esdrujula
				if labeltext$[1] = marca_de_tonica$
					tonica = prepreprebreak
					postonica = tonica + 1
					pospostonica = tonica + 2
					startingtimetonica = Get start point... 'tier_tonicidad' 'tonica'
					endingtimetonica = Get end point... 'tier_tonicidad' 'tonica'
					durtonica = endingtimetonica - startingtimetonica
					mediotonica = startingtimetonica + (durtonica/2)

					startingtimepostonica = Get start point... 'tier_tonicidad' 'postonica'
					endingtimepostonica = Get end point... 'tier_tonicidad' 'postonica'
					durpostonica = endingtimepostonica - startingtimepostonica
					mediopostonica = startingtimepostonica + (durpostonica/2)

					startingtimepospostonica = Get start point... 'tier_tonicidad' 'pospostonica'
					endingtimepospostonica = Get end point... 'tier_tonicidad' 'pospostonica'
					durpospostonica = endingtimepospostonica - startingtimepospostonica
					mediopospostonica = startingtimepospostonica + (durpospostonica/2)



					select PitchTier 'base$'
					f01tonica = Get value at time... 'startingtimetonica'
 					f02tonica = Get value at time... 'mediotonica'
					f03tonica = Get value at time... 'endingtimetonica'

					f02postonica = Get value at time... 'mediopostonica'
					f02pospostonica = Get value at time... 'mediopospostonica'
					f03postonica = Get value at time... 'endingtimepostonica'

					diftonbreak = (12 / log10 (2)) * log10 ('f02pospostonica' / 'f02tonica')

					if diftonbreak >= 'umbral' and f02pospostonica > f02postonica and f02pospostonica > f03postonica and f01posbreak > f03posbreak
						etiquetafinal$ = "H-"
					endif

				endif

				select TextGrid 'base$'
				Insert point... 'tier_Tones' 'timePoint' 'etiquetafinal$'
				Insert point... 'tier_profundo' 'timePoint' 'etiquetafinal$'

			endif


		#acaba bucle de numero de fronteras
		

		endfor
	endif

	
	
##################		Tier normalizado		###############################################
if etiquetaje_normalizado = 1
	select TextGrid 'base$'
	numberOfTiers = Get number of tiers
	Duplicate tier: numberOfTiers, numberOfTiers+1, "Standardization"
	tier_standardization = numberOfTiers+1
	numberOfPoints = Get number of points: tier_standardization
	if numberOfPoints < 1
		selectObject: mySound,myText
		View & Edit
		pause Check why there are no stressed syllables marked in the IP
	endif
	boundaryTone$ = Get label of point: tier_standardization, numberOfPoints
	pitchAccent$ = Get label of point: tier_standardization, numberOfPoints-1
	configuracionNuclear$ = pitchAccent$ + boundaryTone$

	#######################fórmulas de estandarización ########################
	# L*+H L% > L* HL%
	if configuracionNuclear$ = "L*+HL\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L*"
		Set point text: tier_standardization, numberOfPoints, "HL\% "
	endif
	# H*+L L%
	if configuracionNuclear$ = "H*+LL\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "H*"
		Set point text: tier_standardization, numberOfPoints, "L\% "
	endif
	# L*+H HL% > L* HL%
	if configuracionNuclear$ = "L*+HHL\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L*"
		Set point text: tier_standardization, numberOfPoints, "HL\% "
	endif
	# L*+H ¡HL% > L* HL%
	if configuracionNuclear$ = "L*+H\!dHL\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L*"
		Set point text: tier_standardization, numberOfPoints, "HL\% "
	endif
	
	# L* ¡HL% > L* HL%
	if configuracionNuclear$ = "L*\!dHL\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L*"
		Set point text: tier_standardization, numberOfPoints, "HL\% "
	endif
	
	# L+¡H* H% > L+H* H%
	if configuracionNuclear$ = "L+\!dH*H\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L+H*"
		Set point text: tier_standardization, numberOfPoints, "H\% "
	endif
	# L+¡H* HL% > L+H* HL%
	if configuracionNuclear$ = "L+\!dH*HL\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L+H*"
		Set point text: tier_standardization, numberOfPoints, "HL\% "
	endif

	# L+¡H* L¡H% ..>
	if configuracionNuclear$ = "L+\!dH*L\!dH\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L+H*"
		Set point text: tier_standardization, numberOfPoints, "LH\% "
	endif

	#H* L¡H% > H* LH%
	if configuracionNuclear$ = "H*L\!dH\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "H*"
		Set point text: tier_standardization, numberOfPoints, "LH\% "
	endif
	
	#L* ¡HL% > L* HL%
	if configuracionNuclear$ = "L*!dH*L\% " and ((lengua = 2) or (lengua = 3))
			Set point text: tier_standardization, numberOfPoints-1, "L*"
			Set point text: tier_standardization, numberOfPoints, "HL\% "
	endif

	# H* HL% > H* L%
	# if configuracionNuclear$ = "H*HL\% " and ((lengua = 2) or (lengua = 3))
		# Set point text: tier_standardization, numberOfPoints-1, "H*"
		# Set point text: tier_standardization, numberOfPoints, "L\% "
	# endif

	#H+L* L¡H% > L* L!H%
	if configuracionNuclear$ = "H+L*L!H\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L*"
		Set point text: tier_standardization, numberOfPoints, "L!H\% "
	endif

	#L+H* ¡HL% > L+H* HL%
	if configuracionNuclear$ = "L+H*\!dHL\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L+H*"
		Set point text: tier_standardization, numberOfPoints, "HL\% "
	endif

	#L+¡H* ¡HL% > L+H* HL%
	if configuracionNuclear$ = "L+\!dH*\!dH*L\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L+H*"
		Set point text: tier_standardization, numberOfPoints, "HL\% "
	endif

	#L+¡H* L¡H% > L+H* LH%
	if configuracionNuclear$ = "L+\!dH*L\!dH\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L+H*"
		Set point text: tier_standardization, numberOfPoints, "LH\% "
	endif

	#L+H* L¡H% > L+H* LH%
	if configuracionNuclear$ = "L+\!dH*LH\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L+H*"
		Set point text: tier_standardization, numberOfPoints, "LH\% "
	endif

	#H+L* H% > L* H%
	if configuracionNuclear$ = "H+L*H\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L*"
		Set point text: tier_standardization, numberOfPoints, "H\% "
	endif

	#H+L* HL% > L* HL%
	if configuracionNuclear$ = "H+L*HL\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L*"
		Set point text: tier_standardization, numberOfPoints, "HL\% "
	endif

	# Mids 
	#L+H* H!H% > L+H* HL%
	if configuracionNuclear$ = "L+H*H!H\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L+H*"
		Set point text: tier_standardization, numberOfPoints, "HL\% "
	endif
	### VOCATIVOS CANTADOS
	if configuracionNuclear$ = "L+\!dH*!H\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L+H*"
		Set point text: tier_standardization, numberOfPoints, "!H\% "
	endif

	if configuracionNuclear$ = "L+\¡d H*\¡d H!H\% " and ((lengua = 2) or (lengua = 3))
		Set point text: tier_standardization, numberOfPoints-1, "L+H*"
		Set point text: tier_standardization, numberOfPoints, "!H\% "
	endif

	
	
	############## LH% se elige en el formulario
	if d=0
		if configuracionNuclear$ = "L*LH\% " and ((lengua = 2) or (lengua = 3))
			Set point text: tier_standardization, numberOfPoints-1, "L*"
			Set point text: tier_standardization, numberOfPoints, "H\% "
		endif

		if configuracionNuclear$ = "H+L*LH\% " and ((lengua = 2) or (lengua = 3))
			Set point text: tier_standardization, numberOfPoints-1, "L*"
			Set point text: tier_standardization, numberOfPoints, "H\% "
		endif

		if configuracionNuclear$ = "L*+\!dH*LH\% " and ((lengua = 2) or (lengua = 3))
			Set point text: tier_standardization, numberOfPoints-1, "L+H*"
			Set point text: tier_standardization, numberOfPoints, "LH\% "
		endif	
	endif
	

endif


################# borra el etiquetaje fonético en caso de que no se quiera y el nomalizado

	if etiquetaje_superficial = 0
		select textGrid 'base$'
		numberOfTiers = Get number of tiers
		itier = 1
		repeat
			tiername$ = Get tier name... itier
			itier = itier + 1
		until tiername$ = name$ or itier > numberOfTiers
		if tiername$ = "Tones"
            tier_ToBIfonetico = itier
		endif
		Remove tier: itier
	endif
	if etiquetaje_profundo = 0
		select textGrid 'base$'
		numberOfTiers = Get number of tiers
		itier = 1
		repeat
			tiername$ = Get tier name... itier
			itier = itier + 1
		until tiername$ = name$ or itier > numberOfTiers
		if tiername$ = "Tones II"
            tier_profundo = itier
		endif
		Remove tier: itier
	endif

##############	GUARDAR	#####################
	if correccion = 1
		select Sound 'base$'
		plus TextGrid 'base$'
		do ("View & Edit")
		pause ¿Quieres corregir?
	endif
	select TextGrid 'base$'
	#if marca_de_tonica$ = marcatonicacompleja$
	#	do ("Replace interval text...", tier_tonicidad, i, numberOfIntervals, "ˈ", "\'1 ", "Literals")
	#endif

	Save as text file: folder$ + "/"+ base$ + ".TextGrid"

##############	CREAR FIGURAS		#####################
	if create_picture = 1
		picture_width = 7
		select Pitch 'base$'
		minpitch = do ("Get minimum...", 0, 0, "Hertz", "Parabolic")
		maxpitch = do ("Get maximum...", 0, 0, "Hertz", "Parabolic")
		gama = maxpitch - minpitch
		select Sound 'base$'
		To Spectrogram... 0.005 5000 0.002 20 Gaussian
		# Dibuja el oscilograma, espectrograma el pitch, el TextGrid y una caja alrededor de todo ello.
		# Fuente de texto y color
		Times
		Font size: 12
		Line width: 1
		Black

	    Viewport: 0, picture_width, 0, 2
		# Dibuja el oscilograma
		select Sound 'base$'
		Draw... 0 0 0 0 no curve
		# Crea la ventana de imagen para el espectrograma
		Viewport: 0, picture_width, 1, 4
		# Dibuja el espectrograma
		select Spectrogram 'base$'
		Paint... 0 0 0 0 100 yes 50 6 0 no

		# Dibuja el pitch
		# Linea blanca de debajo
		Line width... 10
		White
		Viewport: 0, picture_width, 1, 4
		select Pitch 'base$'
		Smooth: 15
		Draw: 0, 0, minpitch-50, maxpitch+50, "no"

		# Como una linea negra
		Line width... 6
		Black
		Draw: 0, 0, minpitch-50, maxpitch+50, "no"

		# #Dibuja las s de F0. Eje y
		Line width... 1

		# Pone las marcas de f0 máxima y mínima
			minpitch$ = fixed$ (minpitch-50, 0)
			maxpitch$= fixed$ (maxpitch+50, 0)
			minpitch_redondeado = number (minpitch$)
			maxpitch_redondeado = number (maxpitch$)
			maxpitch_redondeado = maxpitch_redondeado/10
			minpitch_redondeado = minpitch_redondeado/10
			maxpitch_redondeado$ = fixed$(maxpitch_redondeado, 0)
			maxpitch_redondeado = number (maxpitch_redondeado$)
			minpitch_redondeado$ = fixed$(minpitch_redondeado, 0)
			minpitch_redondeado = number (minpitch_redondeado$)
			minpitch_redondeado = minpitch_redondeado * 10
			maxpitch_redondeado = maxpitch_redondeado * 10
			One mark left... minpitch_redondeado yes no no
			One mark left... maxpitch_redondeado yes no no


		# Determina cada cuánto (50, 100 o 150Hz) tiene que haber marcas según lo grande que sea el range del hablante
		gamaamplia = gama+100
		if gamaamplia >= 500
			intervalo_entre_marcas = 150
		elsif gamaamplia >= 300
			intervalo_entre_marcas = 100
		elsif gamaamplia < 300
			intervalo_entre_marcas = 50
		endif

		numero_de_marcasf0 = (gamaamplia/intervalo_entre_marcas)+ 1

		# Determina cuál será la primera marca que aparezca en el espectrograma según cuál sea el f0 min que se ha indicado
		minpitch= minpitch-50
		maxpitch= maxpitch+50
		if minpitch >= 250
			marca = 250
		elsif minpitch >= 200
			marca = 200
		elsif minpitch >= 150
			marca = 150
		elsif minpitch >= 100
			marca = 100
		elsif minpitch >= 50
			marca = 50
		elsif minpitch < 50
			marca = 0
		endif

		# Pone las marcas de F0 en Hz según los parámetros anteriores.
		for i to numero_de_marcasf0
			marca = marca + intervalo_entre_marcas
			marca$ = "'marca'"
			if marca <= maxpitch
				do ("One mark left...", 'marca', "yes", "yes", "no", "'marca$'")
			endif
		endfor


		#Dibuja la caja
		Draw inner box
		Draw... 0 0 'minpitch' 'maxpitch' no

		#Determina el texto que aparecerá como título del eje y
			label_of_the_frequency_axis$ = "F0 (Hz)"
		#escribe el título del eje y
		Text left... yes 'label_of_the_frequency_axis$'
		# Label x axis
		label_of_the_time_axis$ = "t (s)"

		#escribe el título del eje x (de tiempo)
		Text top... no 'label_of_the_time_axis$'


		#Pone las marcas del eje de tiempo
		Marks top every... 1 0.1 no yes no
		Marks top every... 1 0.5 yes yes no



		#######################		DIBUJA EL TEXTGRID####################################

		#Busca cuantos tiers hay en el texgrid
		select TextGrid 'base$'
		numberOfTiers = Get number of tiers

		# Define el tamaño de la caja para textgrid según el número de tiers que se ha indicado

		cajatextgrid = (4 + 0.5 * 'numberOfTiers') - 0.02 * 'numberOfTiers'


		# Ventana rosa para los texgrid
		Viewport: 0, picture_width, 1, cajatextgrid


		# Dibuja el TextGrid
		select TextGrid 'base$'
		Draw... 0 0 yes yes no

		# Crea ventana para línea exterior
		Viewport: 0, picture_width, 0, cajatextgrid
		# Dibuja la línea exterior
		Black
		Draw inner box

  		#############################		GUARDA LA IMAGEN		##############################
  		if macintosh = 1
  			Save as PDF file: folder$ +"/"+ base$ + ".pdf"
		endif

		if windows = 1
			Save as 600-dpi PNG file: folder$ + "/" + base$ + ".png"
		endif
		# borra la caja de picture si no dibujaría encima
		Erase all

		#fin del if de crear figura o no
	endif






##############	LIMPIAR		#####################
	select all
	minus Strings list
	Remove

#############	FINAL BUCLE GENERAL	#############
# bucle archivos
endfor

# Limpieza final
select all
Remove

procedure ponetiqueta ()
	select TextGrid 'base$'
		Remove point... 'tier_Tones' 'pointfinal'
		Remove point... 'tier_Tones' 'pointultimatonica'

		Insert point... 'tier_Tones' 't3cola' 'etiquetatono$'
		Insert point... 'tier_Tones' 'endpointcola' 'etiquetafinal$'

	if etiquetaje_profundo =1
		Remove point... 'tier_profundo' 'pointfinal'
		Remove point... 'tier_profundo' 'pointultimatonica'
		Insert point... 'tier_profundo' 't3cola' 'etiquetatonoprofundo$'
		Insert point... 'tier_profundo' 'endpointcola' 'etiquetafinalprofunda$'
	endif
endproc

procedure undefined: value, time
total_duration= Get total duration
timeprimitivo = time
	while value = undefined and time <total_duration
		time= time+0.001
		value = Get value at time: time, "Hertz", "Linear"
	endwhile

	if value = undefined
		time = timeprimitivo
		while value = undefined and time > 0
			time= time-0.001
			value = Get value at time: time, "Hertz", "Linear"
		endwhile
	endif
endproc
