#	Eti_ToBI v.8 (2024)
# Cite as: Elvira-García, W., Roseano, P., Fernández-Planas, A. M., & Martínez-Celdrán, E. (2016). A tool for automatic transcription of intonation: Eti_ToBI a ToBI transcriber for Spanish and Catalan. Language Resources and Evaluation, 50, 767-792.
#
#				DESCRIPTION

#	This is a tool that automatically labels intonational events according to the Sp_ToBI and Cat_ToBI 2015 current systems. T
#	The system consist on a Praat script that assigns ToBI labels from lexical data introduced by the researcher and the
#	acoustical data that it extracts from sound files.  The reliability results for both Cat_ToBI and Sp_ToBI corpora shows
#	a level of agreement equal to the one shown by human transcribers among them in the literature.

# 
#
#
#				INSTRUCTIONS
#	0. Needs 
#		a) a folder with sounds (a sentence in each wav)
#		b) by-syllable textgrid with a mark for the stressed syllables and the same name as the wav (without spaces). You can find wav+textgrid examples at the website
# 		
#	
#	Wendy Elvira-García (2013-2024). Eti-ToBI. [praat script] Retrieved from https://github.com/wendyelviragarcia/eti_ToBI
#	wendy elvira (at) ub.edu
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
	
	#sentence folder /Users/weg/Desktop/test
	comment Your folder should be something like
	comment C:\Users\someName\Desktop (Windows)
	comment or
	comment /Users/someName/Desktop (Mac)

	sentence folder ./data_for_testing/


	# EN EL LAB
	word Marca_de_tonica ˈ
	comment ¿En que número de tier está la marca de tonicidad?
	integer segmentation_tier 1
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

	comment ¿Quieres parar para corregir?
	boolean correccion 0
	boolean create_picture 1
	integer iniciar_en_archivo 1
	boolean Verbose 1


endform

if etiquetaje_profundo = 1 or etiquetaje_normalizado = 1

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
debug = 0
verbose = 1

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
ultimastressed = 0
etiquetaprofunda$ = "* no"
etiquetatonoprofundo$ = " * aguda"
etiquetafinalprofunda$ = "\% "

# for spanish nucleus is always last lexical stress
nucleus_method$ = "manual"

##############	BUCLE GENERAL 	######################
# Crea la lista de objetos desde el string
myFileList= Create Strings as file list: "list", folder$ + "/" + "*"
numberOfFiles = Get number of strings

for stri to numberOfFiles
	filename$ = Get string: stri
	if (right$(filename$, 4) <> ".wav") and (right$(filename$, 4) <> ".WAV")
 		Remove string: stri
 		stri= stri-1
 		numberOfFiles= numberOfFiles-1
 	endif
endfor

numberOfFiles = Get number of strings


if numberOfFiles = 0 
	exitScript: "There are no .wav or .WAV files in folder" + folder$
endif

#allTable = Create Table with column names: "allTable", 0, "file interval humanNPA NPA intensity stringInt range stringRange dur stringDur durPre"

	nucleusData = Create Table with column names: "nucleus", 0, "file nucleus last difInt nucleusRange range lastRange "


#bucle archivos
for ifile from 'from' to numberOfFiles
	stressedstotalesfile= 0

	select Strings list
	soundFile$ = Get string: ifile
	base$ = soundFile$ - ".wav"
	base$ = base$ - ".WAV"
	writeInfoLine: "Working on file " + string$(ifile) + ": "+ base$

	#reads sound
	if fileReadable(folder$ +"/" + soundFile$)
		mySound = Read from file: folder$ +"/" + soundFile$
	else
		exitScript: "No file in " + folder$ + " called " + soundFile$ + "."
	endif

	#reads grid
	if fileReadable(folder$ + "/" +base$ + ".TextGrid")
		myText = Read from file: folder$ + "/" +base$ + ".TextGrid"
	else 
		exitScript: "There are no TextGrids matching your sound " + base$ + ". Check for spaces in filename"
	endif

	numberOfIntervals = Get number of intervals: segmentation_tier
	soundBegins = Get end point: segmentation_tier, 1
	soundEnds = Get start point: segmentation_tier, numberOfIntervals

	#########	CREA OBJETOS ########
	#clean soundwav
	selectObject: mySound 
	filteredSound = Filter (stop Hann band): 2000, 5000, 100
	Rename: base$

	firstPitch = To Pitch: 0.001, f0_min, f0_max

	f0medial = do ("Get mean...", 0, 0, "Hertz")
	@printData("fileMean: " + fixed$(f0medial,0)+"Hz")
	
	#cuantiles teoría de Hirst (2011) analysis by synthesis of speach melody
	q25 = Get quantile: soundBegins, soundEnds, 0.25, "Hertz"
	q75 = Get quantile: soundBegins, soundEnds, 0.75, "Hertz"
	

	if q25 != undefined
		minpitch = q25 * 0.75
	else
		minpitch = f0_min

	endif
	
	if q75 != undefined
		maxpitch = q75 * 1.5
		#set to 2.5 for expressive speech because portuguese range goes over the octave, else 1.5
	else
		maxpitch= f0_max
	endif

	selectObject: filteredSound 
	myPitch = To Pitch: 0.001, minpitch, maxpitch
	Kill octave jumps
	removeObject: firstPitch, filteredSound

	gama = maxpitch - minpitch

	terciogama = gama/3
	tercio1 = minpitch + terciogama
	tercio2 = minpitch + (2*terciogama)
	tercio3 = minpitch + (3*terciogama)
	@printData("Low range less than: "+ fixed$(tercio2,0) +"Hz. Mid range from: "+ fixed$(tercio1,0) + " Hz. High range more than"+ fixed$(tercio2,0)+ "Hz.")
	
	Interpolate
	myPitchTier= Down to PitchTier
	selectObject: mySound
	intensity = To Intensity: 100, 0, "yes"
	intTable = Create Table with column names: "intTable", 0, "interval intensity stringInt range stringRange dur stringDur durPre"




	#########	EMPIEZA EL SCRIPT		#####################

	selectObject: myText
	numberOfIntervals = Get number of intervals: segmentation_tier
	i = 1






	### sustitucion de caracteres
	marcatonicacompleja$ = "\'1"
	if marca_de_tonica$ = marcatonicacompleja$
		select TextGrid 'base$'
		do ("Replace interval text...", segmentation_tier, i, numberOfIntervals, "\'1", "ˈ", "Regular Expressions")

		marca_de_tonica$ = "ˈ"
	endif


	#####################


	if  nuevo_tier_Tones = 1
		Insert point tier... 'tier_Tones' "Tones"
	endif
	if  etiquetaje_profundo = 1
		deep_tier = tier_Tones + 1
		Insert point tier... 'deep_tier' "Tones II"
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
		lastInt = Get number of intervals: segmentation_tier
		lastBoundary = Get end point: segmentation_tier, lastInt
		myPointProcess = Create empty PointProcess: base$, 0, endOfSound
		Add point: lastBoundary
		endIntervalIP = 1
	endif
	

	startIntervalIP = 0
	iIP = 1
	numberOfsyllablesIP = 0

	for iIP from 1 to numberOfIPs
		# get la aparicion iIP de las ip
		stressedstotalesfrase = 0
		
		stressedInventory = Create Table with column names: "stressedInventory", 0, "n nInterval isNucleus"

		selectObject: myPointProcess
		timeOf4Boundary = Get time from index: iIP
		select TextGrid 'base$'
		endIntervalIP = Get interval at time: segmentation_tier, timeOf4Boundary
		endIntervalIP =endIntervalIP-1
		actualInterval=0


		i=1
		for i to endIntervalIP-startIntervalIP
		
			actualInterval = startIntervalIP + i
			numberOfsyllablesIP =numberOfsyllablesIP 

			if actualInterval < numberOfIntervals

				#for i to numberOfIntervals
				numberdesdeelfinal = endIntervalIP - actualInterval
				select TextGrid 'base$'
				labeli$ = Get label of interval: segmentation_tier, actualInterval

				# Hago un array que guarda los caracteres en variables diferentes
				for letra from 1 to numberOfLetras
					labeltext$[letra] = mid$ ("'labeli$'", letra)
				endfor

				if labeltext$[1] = marca_de_tonica$
					ultimastressed = actualInterval
					delayedPeak= 0

					stressedstotalesfrase = stressedstotalesfrase + 1
					stressedstotalesfile = stressedstotalesfile + 1 


					selectObject: stressedInventory
					Append row
					Set numeric value: stressedstotalesfrase, "n", stressedstotalesfrase
					Set numeric value: stressedstotalesfrase, "nInterval", actualInterval



					if nucleus_method$ = "manual"
						if index(labeli$, marca_de_tonica$) != 0
							Set string value: stressedstotalesfrase, "isNucleus", "yes"
						else
							Set string value: stressedstotalesfrase, "isNucleus", "no"
						endif
					else
							Set string value: stressedstotalesfrase, "isNucleus", "no"
					endif




					if ultimastressed < 1
						exitScript: "No stress marks found"
					endif
				
					@printData: ""
					@printData: "Analysing stress syl in interval:" + fixed$(ultimastressed, 0)

					selectObject: myText
					startingpointstressed = Get start point... 'segmentation_tier' 'actualInterval'
					endingpointstressed = Get end point... 'segmentation_tier' 'actualInterval'
					durtonica = endingpointstressed - startingpointstressed
					midstressed = startingpointstressed + (durtonica/2)

					numberOfIntervalPrestressed = actualInterval - (1)
					startingpointprestressed = Get start point... 'segmentation_tier' 'numberOfIntervalPrestressed'
					endingpointprestressed = Get end point... 'segmentation_tier' 'numberOfIntervalPrestressed'
					durpretonica = endingpointprestressed - startingpointprestressed
					midprestressed = startingpointprestressed + (durpretonica/2)
					@printData("tónica centro: " + fixed$(midstressed,0))

					numberOfIntervalpoststressed = actualInterval + 1
					startingpointpoststressed = Get start point... 'segmentation_tier' 'numberOfIntervalpoststressed'
					endingpointpoststressed = Get end point... 'segmentation_tier' 'numberOfIntervalpoststressed'
					durpoststressed = endingpointpoststressed - startingpointpoststressed
					mediopoststressed = startingpointpoststressed + (durpoststressed/2)
					@printData("inicio postónica: " + fixed$(startingpointpoststressed,0)+"medio postónica: " + fixed$(mediopoststressed,0)+"final postónica: " + fixed$(endingpointpoststressed,0) )

					selectObject: intensity
					meanInt = Get mean: startingpointstressed, endingpointpoststressed, "energy"
					if meanInt= undefined
						meanInt = 0
					endif
					
					selectObject: intTable
					Append row

				

					Set numeric value: stressedstotalesfile, "interval", actualInterval
					Set numeric value: stressedstotalesfile, "intensity", meanInt
					stringInt$ = string$(meanInt)
					Set string value: stressedstotalesfile, "stringInt", stringInt$

					select PitchTier 'base$'
					rangeStressed = Get standard deviation (curve): startingpointstressed, endingpointstressed

					selectObject: intTable
					Set numeric value: stressedstotalesfile, "range", rangeStressed
					stringRange$ = string$(rangeStressed)
					Set string value: stressedstotalesfile, "stringRange", stringRange$



					#obtención de valores pitch
					select PitchTier 'base$'
					f01pre = Get value at time... 'startingpointprestressed'
					f02pre = Get value at time... 'midprestressed'
					f03pre = Get value at time... 'endingpointprestressed'
					if numberOfIntervalPrestressed = 1
						f02pre = Get value at time... 'startingpointstressed'
						f01pre = Get value at time... 'startingpointstressed'
						f03pre = Get value at time... 'startingpointstressed'
					endif
					@printData: "Mid pre-stressed value: " + fixed$(midprestressed,0)

					f01ton = Get value at time... 'startingpointstressed'
					f02ton = Get value at time... 'midstressed'
					f03ton = Get value at time... 'endingpointstressed'
					f01pos = Get value at time... 'startingpointpoststressed'
					f02pos = Get value at time... 'mediopoststressed'
					f03pos = Get value at time... 'endingpointpoststressed'

					

					select Pitch 'base$'
					f0tonmax = Get maximum: startingpointstressed, endingpointstressed, "Hertz", "Parabolic"
					if f0tonmax=undefined
						@undefined: f0tonmax, endingpointstressed
						f0tonmax = value
					endif
					f0tonmin = Get minimum: startingpointstressed, endingpointstressed, "Hertz", "Parabolic"
					if f0tonmin=undefined
						@undefined: f0tonmin, endingpointstressed
						f0tonmin = value
					endif

					f0targetpos = Get maximum: startingpointpoststressed, endingpointpoststressed, "Hertz", "Parabolic"
					timeOfPeakPos = Get time of maximum: startingpointpoststressed, endingpointpoststressed, "Hertz", "Parabolic"

					if f0targetpos= undefined
						@undefined: f0targetpos, endingpointpoststressed
						f0targetpos = value
						timeOfPeakPos = time

						if f0targetpos = undefined
							f0targetpos = minpitch
						endif
					endif

					#####	DIFERENCIA EN ST ENTRE DOS FRECUENCIAS	###############

					difpreton = (12 / log10 (2)) * log10 ('f02ton' / 'f02pre')
					diftonpos = (12 / log10 (2)) * log10 ('f02pos' / 'f02ton')
					difton2pos3 = (12 / log10 (2)) * log10 ('f03pos' / 'f02ton')
					difpremaxton = (12 / log10 (2)) * log10 ('f0tonmax' / 'f02pre')
					diftonMidEnd = (12 / log10 (2)) * log10 ('f03ton' / 'f01ton')
					diftontargetpos = (12 / log10 (2)) * log10 ('f0targetpos' / 'f0tonmin')
					diftonmintonmax = (12 / log10 (2)) * log10 ('f0tonmax' / 'f0tonmin')
					@printData: "Prenuclear analysis: Differences between pre/str " + fixed$(difpreton,0) + " str/post "+ fixed$(diftonpos,0)

					################	FORMULAS	####################

					#########	Fórmulas que calculan el pitch accent prenuclear ########################
					#En realidad calculan todos los acentos depués el nuclear se rescribirá
					etiquetatono$= "prenuclear"
					etiquetatonoprofundo$= "prenuclear"

					@printData: ""
					@printData: "Prenuclear formulae"

					###############	Tonos a partir de la mediana ##################
					if abs (difpreton) < 'umbral' and abs (diftontargetpos) < 'umbral' and f02ton < tercio2
						etiquetatono$ = "L*"
						etiquetatonoprofundo$ = "L*"
					@printData: "L*"
					endif

					if abs (difpreton) < 'umbral' and abs (diftontargetpos) < 'umbral' and f02ton >= tercio2
						etiquetatono$ = "H*"
						etiquetatonoprofundo$ = "H*"
					@printData: "H*"
					endif

					#CALCULO DEL TONO EN VEZ DE POR TERCIOS POR DECLINACION
					select TextGrid 'base$'
					numeropuntosahora = Get number of points: 'tier_Tones'

					if numeropuntosahora >=2
						labelstressedprevious$ = Get label of point: tier_Tones, numeropuntosahora-1
						tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora-1
							select PitchTier 'base$'
							f0_puntoanterior = Get value at time: tpuntoanterior
							select TextGrid 'base$'
							intervaloptoanterior = Get interval at time: segmentation_tier, tpuntoanterior
							iniciointervaloanterior = Get start point: segmentation_tier, intervaloptoanterior
							finintervaloanterior = Get end point: segmentation_tier, intervaloptoanterior
							select Pitch 'base$'
							f0maxtonicaanterior = Get maximum: iniciointervaloanterior, finintervaloanterior, "Hertz", "Parabolic"
							if f0maxtonicaanterior = undefined
								@undefined: f0maxtonicaanterior, finintervaloanterior
										f0maxtonicaanterior = value
							endif
							difconlaanterior = (12 / log10 (2)) * log10 (f0maxtonicaanterior / f0_puntoanterior)
							@printData: "Diff from last str. syl peak: " + string$(difconlaanterior)


						if ('difconlaanterior' > 'umbralnegativo') and ((labelstressedprevious$ = "H*") or (labelstressedprevious$ = "L*+H") or (labelstressedprevious$ = "L+H*") or (labelstressedprevious$ = "(L+H*)+H")or (labelstressedprevious$ = "L+(H*+H)") or (labelstressedprevious$ = "L*+(H+H)") or (labelstressedprevious$ = "(L*+H)+H)") or (labelstressedprevious$ = "(L+H*)+L)"))
							pitchaccent$ = "H*"
							etiquetatono$ = "H*"
							etiquetatonoprofundo$ = "H*"
							tonicaH= 1
							@printData: "H*, lack declination from previous point"

						else
							pitchaccent$ = "L*"
							etiquetatono$ = "L*"
							etiquetatonoprofundo$ = "L*"
							tonicaH= 0
							@printData: "L*"

						endif
					endif


					####### Desacentuación
					if difpreton < 'umbralnegativo' and diftonpos < 'umbralnegativo'
						etiquetatono$ = "des"
						etiquetatonoprofundo$= "des"
							@printData: "L*, has been declination from previous point"
					endif


					#etiqueta muy simple debería mirar si el target está en la postónica
					if diftonMidEnd > umbral
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
					if lengua = 3 and diftonMidEnd < 'umbralnegativo'
						etiquetatono$ = "H+L*"
						etiquetatonoprofundo$= "H+L*"
						@printData: "formula pre H+L* preg que"

					endif

					#si puedes mira el pto anterior y pon si el plateu es alto o bajo dependiendo del tono anterior
					select TextGrid 'base$'
					numeropuntosahora = Get number of points: 'tier_Tones'

					if abs (difpreton) < umbral and abs (diftonpos) < 'umbral' and (numeropuntosahora >= 1) and (diftonMidEnd > umbralnegativo)
						labelstressedprevious$ = Get label of point: tier_Tones, numeropuntosahora
						if (labelstressedprevious$ = "H*") or (labelstressedprevious$ = "L*+H") or (labelstressedprevious$ = "L+H*") or (labelstressedprevious$ = "(L+H*)+H")or (labelstressedprevious$ = "L+(H*+H)") or (labelstressedprevious$ = "L*+(H+H)")or (labelstressedprevious$ = "(L*+H)+H)")
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
						@printData: "fórmula prenúcleo L*+H"

					endif

					if abs (diftonmintonmax) < 'umbral' and diftonpos < 'umbralnegativo'
						etiquetatono$ = "H*+L"
						if c = 2
							etiquetatonoprofundo$ = "H*"
						endif
						if c = 1
							etiquetatonoprofundo$ = "H*+L"
						endif
						@printData: "fórmula prenúcleo H*+L"

					endif
					######


					# H+L* PUESTO PARA QUE DIGA DESACENTUADO SI VIENE DE OTRO TONO
					# hay una diferencia en la tónica que pasa el umbral, esa diferencia es negativa, y de la tónica al target de la postónica no pasa el umbral
					if (diftonmintonmax > 'umbral') and (diftonMidEnd < 0) and (abs (diftontargetpos) < 'umbral')
						etiquetatono$ = "H+L*"
						etiquetatonoprofundo$ = "H+L*"

						if lengua = 2 or lengua = 3
							select TextGrid 'base$'
							numeropuntosahora = Get number of points: 'tier_Tones'
							if numeropuntosahora >=1
								labelstressedprevious$ = Get label of point: tier_Tones, numeropuntosahora
								if labelstressedprevious$ ="L*+H" or labelstressedprevious$ ="H+(L*+H)"
									tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora
									intervaloultimotono = Get interval at time: segmentation_tier, tpuntoanterior
									intervalotarget = intervaloultimotono + 1
									inicio_target = Get start point: segmentation_tier, intervaloultimotono
									fin_target = Get end point: segmentation_tier, intervaloultimotono+1
									select Pitch 'base$'
									f0_targetanterior = Get maximum: inicio_target, fin_target, "Hertz", "Parabolic"
									if f0_targetanterior=undefined
										@undefined: f0_targetanterior, fin_target
										f0_targetanterior = value
									endif

									#select PitchTier 'base$'
									#f0_targetanterior = Get value at time: fin_target
									difconlaanterior = (12 / log10 (2)) * log10 ('f02pre' / 'f0_targetanterior')
									@printData: "difconlaanterior: " + fixed$(difconlaanterior, 0)


									if difconlaanterior < umbralnegativo
										etiquetatono$ = "H+L*/L*"
										etiquetatonoprofundo$ = "L*"

										@printData: "fórmula prenúcleo H+L*/L*"

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
							@printData: "fórmula prenúcleo ¡H+L* pretónica extraalta"

						endif
					

					#subida entre la pretonica y la tónica y entre la tónica y la postónica. Y los dos movimientos pasan el umbral.
					if difpreton >= 'umbral' and diftonpos>= 'umbral'
						etiquetatono$ = "L+H*+H"
						@printData: "fórmula prenúcleo L+H*+H"

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
						@printData: "fórmula prenúcleo L*+\!dH*"

					endif

					#  ETIQUETA CUESTIONABLE subida entre la pretónica y la tónica con el pico en el centro de la postónica
					if (diftonmintonmax >= 'umbral') and (diftonMidEnd >0) and (f01pos >= f02ton) and (f02pos >= f01pos) and (f02pos >= f03pos)
						etiquetatono$ = "L+H*+H"
						@printData: "fórmula prenúcleo L+H*+H"

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
							if numeropuntosahora >=1
								labelstressedprevious$ = Get label of point: tier_Tones, numeropuntosahora
								if (labelstressedprevious$ = "L*+H") or (labelstressedprevious$ ="L+(H*+H)") or (labelstressedprevious$ ="(L+H*)+H")
									tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora
									intervaloultimotono = Get interval at time: segmentation_tier, tpuntoanterior
									intervalotarget = intervaloultimotono + 1
									inicio_target = Get start point: segmentation_tier, intervaloultimotono
									fin_target = Get end point: segmentation_tier, intervaloultimotono+1
									select Pitch 'base$'
									f0_targetanterior = Get maximum: inicio_target, fin_target, "Hertz", "Parabolic"
									if f0_targetanterior = undefined
										@undefined: f0_targetanterior, fin_target
										f0_targetanterior = value
									endif
									#select PitchTier 'base$'
									#f0_targetanterior = Get value at time: fin_target
									difconlaanterior = (12 / log10 (2)) * log10 ('f0tonmin' / 'f0_targetanterior')
									if difconlaanterior < umbralnegativo
										etiquetatonoprofundo$ = "L*+H"
									endif
								endif
							endif
						endif

						@printData: "fórmula prenúcleo H+L*+H"
					endif


				



					##########	ESCRIBE LA ETIQUETA QUE HA SALIDO DE LAS FORMULAS	##################
					select TextGrid 'base$'
					Insert point... 'tier_Tones' 'midstressed' 'etiquetatono$'
					if etiquetaje_profundo = 1
						Insert point... 'deep_tier' 'midstressed' 'etiquetatonoprofundo$'
					endif

					##############
				# acaba el if de condición de la sílaba contiene marca de tónica
				endif
			# acaba el if de si el numero de intervalo es más pequeño que el final
			endif
			#acaba bucle de todos los intervalos de IP


		endfor




		#####################	ACCIONES PARA LA ULTIMA TÓNICA 	##############
		#ahora el número de intervalo de la ultima tonica de la frase está almacenada en ultimastressed
	
	@printData: "--"
	@printData: "NUCLEAR CONFIGURATION"

		if ultimastressed < 1
			pause There are not stressed syllables
		endif


		###
		# decide where is the nucleus
		##
		selectObject: intTable
		
		int1 = Get value: stressedstotalesfile, "intensity"
		if stressedstotalesfile > 2
			int2 = Get value: 2, "intensity"
		else
			int2= 0
		endif


		intFirst= int1
		intLast = Get value: stressedstotalesfile, "intensity"
		difInt = intLast-intFirst 
		if difInt< -5
			early = 1
			selectObject: intTable
			nOfRows = Get number of rows
			for row to nOfRows
				value= Get value: row, "intensity"
				if value = undefined
					Set numeric value: row, "intensity", 0
				endif
			endfor
			
			max = Get maximum: "intensity"
			if max = undefined
				max = 0
			endif
			strMax$ = string$(max)
			row = Search column: "stringInt", strMax$
		else 
			early= 0
			row = stressedstotalesfile
		endif

		### nucleus by range
		maxR = Get maximum: "range"
		if maxR = undefined
				maxR = 0
		endif
			strMaxR$ = string$(maxR)
		rowR = Search column: "stringRange", strMaxR$

		if rowR = stressedstotalesfile
			early = 0
		else
			early=1
		endif





		selectObject: nucleusData
		Append row
		Set string value: ifile, "file", base$
		Set numeric value: ifile, "nucleus", row
		Set numeric value: ifile, "difInt", difInt
		#by range
		Set numeric value: ifile, "nucleusRange", rowR
		Set numeric value: ifile, "range", maxR


		if row = stressedstotalesfile
			Set string value: ifile, "last", "yes"
		else
			Set string value: ifile, "last", "no"
		endif


		if rowR = stressedstotalesfile
			Set string value: ifile, "lastRange", "yes"
		else
			Set string value: ifile, "lastRange", "no"
		endif

		
		selectObject: stressedInventory
		nucl= Search column: "isNucleus", "yes"





		select TextGrid 'base$'
		startingpointlastton = Get start point: segmentation_tier, ultimastressed
		endingpointlastton = Get end point: segmentation_tier, ultimastressed
		ultimasilaba = endIntervalIP
		endingpointlastsyl = Get end point: segmentation_tier, ultimasilaba
		durlastton = endingpointlastton - startingpointlastton

		stressType = ultimasilaba - ultimastressed

		mediolastton = startingpointlastton + (durlastton/2)
		parteslastton=  durlastton/6
		t4lastton = parteslastton*2
		t5lastton = parteslastton*4

		# pretónica de la última tonica
		pretonlastton = ultimastressed - 1
		startingpointprelastton = Get start point... 'segmentation_tier' 'pretonlastton'
		endingpointprelastton = Get end point... 'segmentation_tier' 'pretonlastton'
		durprelastton = endingpointprelastton - startingpointprelastton
		medioprelastton = startingpointprelastton + (durprelastton/2)

		# postónica de la última tonica
		postonlastton = ultimastressed + 1
		startingpointposlastton = Get start point... 'segmentation_tier' 'postonlastton'
		endingpointposlastton = Get end point... 'segmentation_tier' 'postonlastton'
		durposlastton = endingpointposlastton - startingpointposlastton
		medioposlastton = startingpointposlastton + (durposlastton/2)
		parteslastpos=  durposlastton/6
		t4lastpos = parteslastpos*2
		t5lastpos = parteslastpos*4



		if stressType =0
			@printData: "Oxytone"

			select TextGrid 'base$'
			endingpointlastton = startingpointlastton+ durlastton/2
			durlastton = endingpointlastton-startingpointlastton
			mediolastton = startingpointlastton + (durlastton/2)
			parteslastton=  durlastton/6
			t4lastton = parteslastton*2
			t5lastton = parteslastton*4

			startingpointposlastton = endingpointlastton
			endingpointposlastton = Get end point: segmentation_tier, ultimastressed
			durposlastton = endingpointposlastton - startingpointposlastton
			medioposlastton = startingpointposlastton + (durposlastton/2)
			parteslastpos=  durposlastton/6
			t4lastpos = parteslastpos*2
			t5lastpos = parteslastpos*4
		else
			@printData: "Non-oxytone"

			select TextGrid 'base$'
			mediolastton = startingpointlastton + (durlastton/2)
			parteslastton=  durlastton/6
			t4lastton = parteslastton*2
			t5lastton = parteslastton*4

			postonlastton = ultimastressed + 1
			startingpointposlastton = Get start point... 'segmentation_tier' 'postonlastton'
			endingpointposlastton = Get end point... 'segmentation_tier' 'postonlastton'
			durposlastton = endingpointposlastton - startingpointposlastton
			middleposlastton = startingpointposlastton + (durposlastton/2)
			parteslastpos=  durposlastton/6
			t4lastpos = parteslastpos*2
			t5lastpos = parteslastpos*4	
		endif



		# compute F0 differences
		select PitchTier 'base$'


		if numberOfIntervalPrestressed = 1
			startingpointlastton= startingpointlastton+0.05
			middleprelastton = startingpointlastton
		elsif numberOfIntervalPrestressed = 2
			startingpointprelastton = startingpointprelastton+0.05
		endif



		f01pre = Get value at time... 'startingpointprelastton'
		f02pre = Get value at time... 'medioprelastton'
		f03pre = Get value at time... 'endingpointprelastton'



		f01ton = Get value at time... 'startingpointlastton'
		f02ton = Get value at time... 'mediolastton'
		f03ton = Get value at time... 'endingpointlastton'
		f04ton = Get value at time... 't4lastton'
		f05ton = Get value at time... 't5lastton'
		


		@printData: "Last str syl: start" + fixed$(f01ton, 0) + "Hz. Mid: "+ fixed$(f02ton, 0) + "Hz. End: " +fixed$(f03ton, 0)
		@printData: "Last str syl: near start" + fixed$(f04ton, 0) + "Hz. Near end: "+ fixed$(f05ton, 0)




		# si no hay pretonica, los valores de la pretonica son los valores de inicio de la tónica
		if numberOfIntervalPrestressed = 1
			f02pre = f01ton
		endif
		
		f0fin = Get value at time... 'endingpointlastsyl'-0.05

		f01pos = Get value at time... 'startingpointposlastton'
		f02pos = Get value at time... 'medioposlastton'
		f03pos = Get value at time... 'endingpointposlastton'
		f04pos = Get value at time... 't4lastpos'
		f05pos = Get value at time... 't5lastpos'

		#elige valor más alto...
		#f0maxton = max (f01ton, f02ton,f03ton,f04ton,f05ton)

		selectObject: myPitch
		f0maxton = Get maximum: startingpointlastton, endingpointlastton, "Hertz", "Parabolic"
		whereMax= Get time of maximum: startingpointlastton, endingpointlastton, "Hertz", "Parabolic"

		if f0maxton= undefined
			@undefined: f0maxton, endingpointlastton
			f0maxton = value
			whereMax = time
		endif

		@printData: "Last pres syl:" + fixed$(f02pre, 0) + "Last post: "+ fixed$(f02pos, 0)



		##### 	calculos semitonos ultima tonica #######
		difpreton = (12 / log10 (2)) * log10 ('f02ton' / 'f02pre')
		diftonpos = (12 / log10 (2)) * log10 ('f02pos' / 'f02ton')	
		difpospos = (12 / log10 (2)) * log10 ('f03pos' / 'f01pos')
		diftonMidEnd = (12 / log10 (2)) * log10 ('f03ton' / 'f02ton')
		diftonStartMid = (12 / log10 (2)) * log10 ('f02ton' / 'f01ton')
		diftonMidStartMid = (12 / log10 (2)) * log10 ('f02ton' / 'f04ton')

		diftonStartEnd = (12 / log10 (2)) * log10 ('f03ton' / 'f01ton')
		difprepre = (12 / log10 (2)) * log10 ('f03pre' / 'f01pre')
		diftonfin = (12 / log10 (2)) * log10 ('f0fin' / 'f02ton')
		difpremaxton = (12 / log10 (2)) * log10 ('f0maxton' / 'f02pre')
		diftonmaxton = (12 / log10 (2)) * log10 ('f0maxton' / 'f01ton')
		difposfin= (12 / log10 (2)) * log10 ('f0fin' / 'f02pos')


		@printData: "Differences"
		@printData: "Dif pre/pre: " + string$(difprepre) 
		@printData: "Dif pre/str: " + string$(difpreton) + "st. Dif str/pos: " + string$(diftonpos) +" st."
		@printData: "Dif within stressed syl" 
		@printData: "Start-End: "+ string$(diftonStartEnd)+ "st. Start-Mid " + fixed$(diftonStartMid,0) +"st. Mid-End: " + string$(diftonMidEnd)+"st."

		


		########### FORMULAS ULTIMA TÓNICA NO AGUDA	###########
		
		@printData: ""
		@printData: "Last stressed syl formulae"
		

		pitchaccent$ = ""
		etiquetatono$ = "última-tónica-no-aguda"
		etiquetaprofunda$ = "última-tónica-no-aguda"


			#CALCULO DEL TONO EN VEZ DE POR TERCIOS POR DECLINACION
			select TextGrid 'base$'
			numeropuntosahora = nucl-1

			labelstressedprevious$ = ""
			if numeropuntosahora >=1
				tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora
				labelstressedprevious$ = Get label of point: tier_Tones, numeropuntosahora
				select PitchTier 'base$'
				f0_puntoanterior = Get value at time: tpuntoanterior
				select TextGrid 'base$'
				intervaloptoanterior = Get interval at time: segmentation_tier, tpuntoanterior
				iniciointervaloanterior = Get start point: segmentation_tier, intervaloptoanterior
				fintargetanterior = startingpointprelastton

				select Pitch 'base$'
				f0maxtargetanterior = Get maximum: iniciointervaloanterior, fintargetanterior, "Hertz", "Parabolic"
				if f0maxtargetanterior = undefined
					@undefined: f0maxtargetanterior, fintargetanterior
							f0maxtargetanterior = value
				endif
				difconlaanterior = (12 / log10 (2)) * log10 (f01ton / f0maxtargetanterior)
				@printData: "Movement since last target " + fixed$(difconlaanterior, 2) + " St"

				if difconlaanterior < umbralnegativo
					pitchaccent$ = "L*"
					etiquetatono$ = "L*"
					etiquetaprofunda$ = "L*"
					tonicaH =0
				endif
				if ('difconlaanterior' > 'umbralnegativo') 
					if ((labelstressedprevious$ = "H*") or (labelstressedprevious$ = "L*+H") or (labelstressedprevious$ = "L+H*") or (labelstressedprevious$ = "(L+H*)+H") or (labelstressedprevious$ = "L+(H*+H)") or (labelstressedprevious$ = "L*+(H+H)") or (labelstressedprevious$ = "(L*+H)+H)") or (labelstressedprevious$ = "(L+H*)+L)") or (labelstressedprevious$ = "L+(H*+L)"))
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
				if ('difconlaanterior' < 'umbralnegativo') and ((labelstressedprevious$ = "H*") or (labelstressedprevious$ = "L*+H") or (labelstressedprevious$ = "L+H*") or (labelstressedprevious$ = "(L+H*)+H")or (labelstressedprevious$ = "L+(H*+H)") or (labelstressedprevious$ = "L*+(H+H)") or (labelstressedprevious$ = "(L*+H)+H)") or (labelstressedprevious$ = "(L+H*)+L)"))
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
			endif

		
		
		
		if diftonpos > umbral and pitchaccent$ = "H*"
			etiquetatono$ = "L*+H"
			etiquetaprofunda$ = "L*+H"
			tonicaH = 1
		endif
		
		
		if abs (difpreton) < 'umbral' and pitchaccent$ = "L*"
			etiquetatono$ = "L*"
			etiquetaprofunda$ = "L*"
			tonicaH = 0
				@printData: "L*"
		endif

		if abs (difpreton) < 'umbral' and pitchaccent$ = "H*"
			etiquetatono$ = "H*"
			etiquetaprofunda$ = "H*"
			tonicaH = 1
				@printData: "H*"
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

			@printData: "Bajada en la pretónica (tónica baja), noes un tono fonológico en español"

			if (!lengua = 3) and (!lengua= 2)
			etiquetaprofunda$ = "H+L*"
			@printData: "H+L* Bajada en la pretónica (tónica baja)"

			endif
		endif

		if abs (difpreton) < 'umbral' and diftonMidEnd < 'umbralnegativo'
			etiquetatono$ = "H*+L"
			etiquetaprofunda$ = "H*+L"
			tonicaH=0
			if c = 0
				etiquetaprofunda$ = "H*"
			endif
			tonicaH = 1
			@printData: "H*+L" 
		endif

		# H+L* PUESTO PARA QUE DIGA DESACENTUADO SI VIENE DE OTRO TONO
		#calcula si ha habido declinación entre el último tono y la prétonica del tono actual. Si ha pasado significa que no hay un target alto en la pretónica por tanto, no es H+L*
		if diftonStartEnd < 'umbralnegativo'
			etiquetatono$ = "H+L*"
			etiquetaprofunda$ = "H+L*"
			tonicaH=0
			if lengua = 3 or lengua =2
				select TextGrid 'base$'
					numeropuntosahora = nucl-1
				if numeropuntosahora >=1
					labelstressedprevious$ = Get label of point: tier_Tones, numeropuntosahora

					if numeropuntosahora >1
						tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora-1

						intervaloultimotono = Get interval at time: segmentation_tier, tpuntoanterior
						labeltonoanterior$ = Get label of point: tier_Tones, numeropuntosahora-1

						if (labeltonoanterior$ = "L*+H") or (labeltonoanterior$ = "H+(L*+H)") or (labeltonoanterior$ = "(H+L*)+H") or (labeltonoanterior$ = "(L+H*)+H") or (labeltonoanterior$ = "L+(H*+H)")
							inicio_target = Get start point: segmentation_tier, intervaloultimotono+1
							fin_target = Get end point: segmentation_tier, intervaloultimotono+1
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
						inicio_frase = Get start point: segmentation_tier, 2
						select PitchTier 'base$'
						target_anterior = Get value at time: inicio_frase
					endif

					#aquí si pongo con el pto 3 de la pretónica deja de ver los H+L*
					difconlaanterior = (12 / log10 (2)) * log10 ('f01pre' / 'target_anterior')


					if numeropuntosahora <= 1 and difconlaanterior < 'umbralnegativo'
						etiquetatono$ = "H+L*"
						etiquetaprofunda$ = "L*"
						tonicaH= 0
						@printData: "H+L*" 

					endif

					if (numeropuntosahora > 1) and (labelstressedprevious$ <> "H+L*") and (labelstressedprevious$ <> "H+(L*+H)") and (difconlaanterior < 'umbralnegativo')
						etiquetatono$ = "H+L*"
						etiquetaprofunda$ = "L*"
						tonicaH=0
					endif
				endif
			endif
			@printData: "H+L* fonético" 

		endif


		



		# H+L* PUESTO PARA QUE DIGA DESACENTUADO SI VIENE DE OTRO TONO
		#esta mira si el tono H que hay en la pretónica es la postónica del tono H de un tono anterior y entonces le coloca sólo la L*
		#FALTA COLOCARLE LA DECLINACION PORQUE SINO DESACENTUARÁ COSAS QUE NO TOCAN
		if diftonStartEnd < 'umbralnegativo'
			tonicaH = 0
			#busca si el intervalo actual -2 es una tónica (eso quiere decir que la pretónica de la tónica actual es la postónica de otro tono y si ese otro tono tiene un pico pospuesto no coloca H a la pretónica del actual)
				select TextGrid 'base$'
				numeropuntosahora = Get number of points: tier_Tones
				if numeropuntosahora >1
					#busca el último tono
					tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora-1
					intervaloultimotono = Get interval at time: segmentation_tier, tpuntoanterior

					if intervaloultimotono = ultimastressed-2
						labeltonoanterior$ = Get label of point: tier_Tones, numeropuntosahora-1
						if (labeltonoanterior$ = "L*+H") and diftonmaxton > 'umbral'
							etiquetatono$ = "H+L*"
							etiquetaprofunda$ = "L*"
										@printData: "H+L* --> L*" 

							tonicaH=0
						endif
					endif
				endif

		endif




		if (difpreton >= 'umbral') or (diftonStartEnd >= 'umbral') or (diftonmaxton >= umbral)
			etiquetatono$ = "L+H*"
			etiquetaprofunda$ = "L+H*"
			tonicaH = 1
			@printData: "L+H*" 

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
			if (difpreton>= umbral or (diftonStartEnd>=umbral)) and diftonfin >= umbral
				# si la subida en la primera mitad de la tónica no pasa el umbral... Y el tono empieza bajo, si no puede ser una suspendida
				select TextGrid 'base$'
				numberpoints = Get number of points: tier_Tones
				if pitchaccent$ = "L*" and ((diftonStartMid < umbral) or (diftonMidEnd<umbral) or (diftonStartEnd<umbral) or (f01ton > f02ton)) and (numberpoints > 1)
					etiquetatono$ = "L+H*"
					etiquetaprofunda$ = "L*"
								@printData: "L+H*--> L*" 

					tonicaH = 1
				endif
			endif
		endif



		if (difpremaxton >= umbral_upstep) and ((lengua = 3) or (lengua = 2))
			etiquetatono$ = "L+\!dH*"
			etiquetaprofunda$ = "L+\!dH*"
											@printData: "L+¡H*" 

			if b= 2
			etiquetaprofunda$ = "L+H*"
			endif
			tonicaH = 1
		endif



		# ¡H calculada como las extraaltas del catalan solo con que sea más alta, no tiene que pasar el umbral
		#si esta subida se cumple pero lo anterior es un plateau alto
		#COSAS RARAS PARA DOS ALINEACIONES DE TONO Y PARA LAS ¡H QUE SON ¡ PORQUE SON MÁS ALTAS QUE UNA H ANTERIOR
		# las de como si no pasan el umblral se quedan sobre 1.2St
		if 	(difpreton>= 'umbral') and ((diftonMidEnd < 'umbralnegativo') or (diftonpos < 'umbralnegativo')) and (abs (difpreton) < abs (diftonpos))
			etiquetatono$ = "(L+H*)+L"
			etiquetaprofunda$ = "H*+L"

			@printData: "H*+L" 

			tonicaH=0
			if c = 0
				etiquetaprofunda$ = "L+H*"
			endif

			if lengua= 2 or lengua= 3 and difpremaxton >= 'umbral_upstep'
				etiquetatono$ = "(L+\!dH*)+L"
				etiquetaprofunda$ = "L+\!dH*"
				tonicaH = 1

				if b= 2
				etiquetaprofunda$ = "L+H*"
				endif
			endif

			select TextGrid 'base$'
			numeropuntosahora = Get number of points: 'tier_Tones'
			if numeropuntosahora >=2
				labelstressedprevious$ = Get label of point: tier_Tones, numeropuntosahora-1
				tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora-1
					select PitchTier 'base$'
					f0_puntoanterior = Get value at time: tpuntoanterior
					difconlaanterior = (12 / log10 (2)) * log10 ('f01pre' / 'f0_puntoanterior')

				if  lengua = 2 and ('difconlaanterior' > 'umbralnegativo') and ((labelstressedprevious$ = "H*") or (labelstressedprevious$ = "L*+H") or (labelstressedprevious$ = "L+H*") or (labelstressedprevious$ = "(L+H*)+H")or (labelstressedprevious$ = "L+(H*+H)") or (labelstressedprevious$ = "L*+(H+H)")or (labelstressedprevious$ = "(L*+H)+H)") or (labelstressedprevious$ = "(L+H*)+L)"))
					etiquetatono$ = "\!dH*"
					etiquetaprofunda$= "\!dH*"
					tonicaH = 1

					@printData: "¡H* (como si Sevilla, preg Canarias etc.)" 


				else
					@printData: "L+H* (prueba para cuando es L+\!dH* por los 6 st)" 
					if difpremaxton >= umbral_upstep
						etiquetatono$ = "L+\!dH*"
						etiquetaprofunda$= "L+\!dH*"
						tonicaH = 1

						if b= 2
							etiquetaprofunda$ = "L+H*"
						endif
						@printData: "L+\!dH para las preg parciales del catalán" 

					endif
				endif
			endif
			tonicaH = 0
		endif


		######## escribe etiqueta de la última tónica ##########
		select TextGrid 'base$'
		numberOfPoints = Get number of points: tier_Tones
		if numberOfPoints < 1
			exitScript: "No stressed syl anal."
		endif

		#each new IP adds a boundary tone that is not counted in the nucl but it is a point
		# so we add the a point for each IP 

		if iIP = 1 
			Remove point: tier_Tones, numberOfPoints

			#Remove point: tier_Tones, stressedstotalesfile
			Insert point: tier_Tones, mediolastton, etiquetatono$
		else
			Remove point: tier_Tones, numberOfPoints
			#Remove point: tier_Tones, stressedstotalesfile +iIP-1
			Insert point: tier_Tones, mediolastton, etiquetatono$
		endif


		if etiquetaje_profundo = 1
			if iIP = 1 
				Remove point: deep_tier, numberOfPoints 
				Insert point: deep_tier, mediolastton, etiquetaprofunda$
			else
				Remove point: deep_tier, numberOfPoints
				Insert point: deep_tier, mediolastton, etiquetaprofunda$
			endif
		endif

		#######################			TONOS JUNTURA			#######################

		ultimasilaba = endIntervalIP




		select TextGrid 'base$'
		endingpointlastsyl = Get end point... 'segmentation_tier' 'ultimasilaba'
		stressType = ultimasilaba - ultimastressed
		#dice si es aguda
		if stressType = 0
			@printData: "Stress type oxytone, applying oxytone formulae"

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
			f012cola = Get value at time... 't12cola'-0.05


			



			select TextGrid 'base$'
			pointultimastressed = Get number of points... 'tier_Tones'


			select Pitch 'base$'
			f0maxprimeramitaddecola = Get maximum: f03cola, f06cola, "Hertz", "Parabolic"
			if f0maxprimeramitaddecola = undefined
				f0maxprimeramitaddecola = f06cola
			endif

			f0minprimeramitaddecola = Get minimum: f03cola, f06cola, "Hertz", "Parabolic"
			if f0minprimeramitaddecola = undefined
				f0minprimeramitaddecola = f06cola
			endif



			##### Formulas para calcular tonos de frontera monotonales
			dif126 = (12 / log10 (2)) * log10 ('f012cola' / 'f06cola')
			difpre3 = (12 / log10 (2)) * log10 ('f03cola' / 'f02pre')
			difpre6 = (12 / log10 (2)) * log10 ('f06cola' / 'f02pre')
			dif96 = (12 / log10 (2)) * log10 ('f09cola' / 'f06cola')
			dif129 = (12 / log10 (2)) * log10 ('f012cola' / 'f09cola')
			dif63 = (12 / log10 (2)) * log10 ('f06cola' / 'f03cola')
			dif12max = (12 / log10 (2)) * log10 ('f012cola' / 'f0maxton')
			
			
			selectObject: myText
			#pone un punto vacío para tener que borrar los dos últimos puntos en todos los casos
			Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
			if etiquetaje_profundo = 1
				Insert point... 'deep_tier' 't12cola' 'etiquetafinalprofunda$'
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
					Remove point... 'deep_tier' 'pointfinal'
					Insert point... 'deep_tier' 't12cola' 'etiquetafinalprofunda$'
				endif
				@printData: "etiqueta final L%"
			endif

			if tonicaH = 0 and dif126 >= 'umbral'
				etiquetafinal$ = "H\% "
				etiquetafinalprofunda$ = "H\% "
				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'deep_tier' 'pointfinal'
					Insert point... 'deep_tier' 't12cola' 'etiquetafinalprofunda$'
				endif
				@printData: "etiqueta final H%"
			endif

			#formulacalculomid
			if tonicaH = 0 and dif126 >= 'umbral' and f012cola <= tercio2
				etiquetafinal$ = "!H\% "
				etiquetafinalprofunda$ = "!H\% "

				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'deep_tier' 'pointfinal'
					Insert point... 'deep_tier' 't12cola' 'etiquetafinalprofunda$'
				endif
				@printData: "etiqueta final !H%"
			endif


			#monotonales después de H
			if tonicaH = 1 and dif126 >= 'umbralnegativo'
				etiquetafinal$ = "H\% "
				etiquetafinalprofunda$ = "H\% "

				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'deep_tier' 'pointfinal'
					Insert point... 'deep_tier' 't12cola' 'etiquetafinalprofunda$'
				endif
				@printData: "etiqueta final H%"
			endif




			if tonicaH = 1 and dif126 < 'umbralnegativo'
				etiquetafinal$ = "L\% "
				etiquetafinalprofunda$ = "L\% "

				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'deep_tier' 'pointfinal'
					Insert point... 'deep_tier' 't12cola' 'etiquetafinalprofunda$'
				endif
			endif

			if tonicaH = 1  and (f012cola > tercio1) and ((dif126 < 'umbralnegativo') or (dif12max<'umbralnegativo'))
				etiquetafinal$ = "!H\% "
				etiquetafinalprofunda$ = "!H\% "
				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'deep_tier' 'pointfinal'
					Insert point... 'deep_tier' 't12cola' 'etiquetafinalprofunda$'
				endif
								@printData: "etiqueta final !H%"

			endif

			if tonicaH = 1  and (f012cola > tercio1) and (dif12max<1) and durcola>0.60
				etiquetafinal$ = "!H\% "
				etiquetafinalprofunda$ = "!H\% "
				Remove point... 'tier_Tones' 'pointfinal'
				Insert point... 'tier_Tones' 't12cola' 'etiquetafinal$'
				if etiquetaje_profundo = 1
					Remove point... 'deep_tier' 'pointfinal'
					Insert point... 'deep_tier' 't12cola' 'etiquetafinalprofunda$'
				endif
				@printData: "etiqueta final !H%"

			endif


			########## BITONALES
			etiquetatono$= "ultima-tonica-aguda"
			etiquetatonoprofundo$= "ultima-tonica-aguda"
			etiquetafinal$ = "tonema-agudo"
			pitchaccent$ = ""

			#CALCULO DEL TONO EN VEZ DE POR TERCIOS POR DECLINACION
			select TextGrid 'base$'
			numeropuntosahora = Get number of points: 'tier_Tones'
			if numeropuntosahora >=3
				labelstressedprevious$ = Get label of point: tier_Tones, numeropuntosahora-1
				tpuntoanterior = Get time of point: tier_Tones, numeropuntosahora-1
					select PitchTier 'base$'
					f0_puntoanterior = Get value at time: tpuntoanterior
					select TextGrid 'base$'
					intervaloptoanterior = Get interval at time: segmentation_tier, tpuntoanterior
					iniciointervaloanterior = Get start point: segmentation_tier, intervaloptoanterior
					fintargetanterior = Get end point: segmentation_tier, intervaloptoanterior+1
					select Pitch 'base$'
					f0maxtonicaanterior = Get maximum: iniciointervaloanterior, fintargetanterior, "Hertz", "Parabolic"
					if f0maxtonicaanterior = undefined
						@undefined: f0maxtonicaanterior, fintargetanterior
								f0maxtonicaanterior = value
					endif
					difconlaanterior = (12 / log10 (2)) * log10 (f01ton / f0maxtonicaanterior)

				if ('difconlaanterior' > 'umbralnegativo') and ((labelstressedprevious$ = "H*") or (labelstressedprevious$ = "L*+H") or (labelstressedprevious$ = "L+H*") or (labelstressedprevious$ = "(L+H*)+H")or (labelstressedprevious$ = "L+(H*+H)") or (labelstressedprevious$ = "L*+(H+H)") or (labelstressedprevious$ = "(L*+H)+H)") or (labelstressedprevious$ = "(L+H*)+L)"))
					pitchaccent$ = "H*"
				else
					pitchaccent$ = "L*"
				endif

			else
				difconlaanterior = (12 / log10 (2)) * log10 ('f02ton' / 'f02pre')

				if ('difconlaanterior' < 'umbralnegativo') and ((labelstressedprevious$ = "H*") or (labelstressedprevious$ = "L*+H") or (labelstressedprevious$ = "L+H*") or (labelstressedprevious$ = "(L+H*)+H")or (labelstressedprevious$ = "L+(H*+H)") or (labelstressedprevious$ = "L*+(H+H)") or (labelstressedprevious$ = "(L*+H)+H)") or (labelstressedprevious$ = "(L+H*)+L)"))
					pitchaccent$ = "L*"
				else

					if f01ton > tercio2
						pitchaccent$ = "H*"
					endif
					if f01ton < tercio2
						pitchaccent$ = "L*"
					endif
				endif
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

					@printData: "fórmula monotonales-agudasalineacionespecial H* L%--> L*L%"

					!H
				endif
			endif

			if pitchaccent$ = "H*" and ((abs (difpre3)) < 'umbral') and dif126 < 'umbralnegativo'
				etiquetatono$ = "H*"
				etiquetatonoprofundo$ = "H*"
				etiquetafinal$ = "L\% "
				etiquetafinalprofunda$= "L\% "
				@ponetiqueta ()
				@printData: "fórmula monotonales-agudasalineacionespecial H* L%"

			endif





			################################################


			if pitchaccent$ = "L*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral') )
				... and (dif96 >= 'umbral' and dif129 < 'umbralnegativo')
				etiquetatono$ = "L*"
				etiquetatonoprofundo$ = "L*"
				etiquetafinal$ = "HL\% "
				etiquetafinalprofunda$= "HL\% "
				@ponetiqueta ()
				@printData: "fórmula 1 L* HL%"
			endif


			if pitchaccent$ = "L*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif96 >= 0.50 and dif129 < -0.50) and durcola > 0.50
				etiquetatono$ = "L*"
				etiquetatonoprofundo$ = "L*"
				etiquetafinal$ = "L\% "
				etiquetafinalprofunda$= "HL\% "
				@ponetiqueta ()
				@printData: "fórmula 1 L* HL%"

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
				@printData: "fórmula 2 L* HL % con otra alineación"


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
								@printData: "fórmula 3 L* HL % "

			endif



			if pitchaccent$ = "L*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and ((dif96 >= 'umbral') and (dif129 < 'umbralnegativo') and (f012cola > tercio1))
				etiquetatono$ = "L*"
				etiquetafinal$ = "H!H\% "
				etiquetatonoprofundo$ = "L*"
				etiquetafinalprofunda$ = "H!H\% "
				@ponetiqueta ()
				@printData: "fórmula 5 L* H!H%"

			endif

			if  pitchaccent$ = "L*" and difconlaanterior > 'umbralnegativo' and difpre3 < 'umbralnegativo'
				... and dif96 >= 'umbral' and dif129 < 'umbralnegativo'
				etiquetatono$ = "H+L*"
				etiquetafinal$ = "HL\% "
				etiquetatonoprofundo$ = "H+L*"
				etiquetafinalprofunda$ = "HL\% "

				@ponetiqueta ()
				@printData: "fórmula 6 H+L* HL%"


			endif


			if  pitchaccent$ = "L*" and difconlaanterior > 'umbralnegativo' and difpre3 < 'umbralnegativo'
				... and dif63 > 0.50 and dif129 < -0.50 and durcola > 0.50
				etiquetatono$ = "H+L*"
				etiquetafinal$ = "L\% "
				etiquetatonoprofundo$ = "H+L*"
				etiquetafinalprofunda$ = "HL\% "

				@ponetiqueta ()
				@printData: "fórmula 6,5 H+L* HL% con duración"

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
					@printData: "fórmula 7 H+L* LH%"

			endif

			if  pitchaccent$ = "L*" and difconlaanterior > 'umbralnegativo' and difpre3 < 'umbralnegativo'
				... and (dif96 < 'umbral' or dif96 >= 'umbralnegativo') and dif129 >= 'umbral' and f012cola < tercio2
				etiquetatono$ = "H+L*"
				etiquetafinal$ = "L!H\% "
				etiquetatonoprofundo$ = "H+L*"
				etiquetafinalprofunda$ = "L!H\% "

				@ponetiqueta ()
						@printData: "fórmula 8 H+L* L!H%"

			endif

			if   pitchaccent$ = "L*" and difconlaanterior > 'umbralnegativo' and difpre3 < 'umbralnegativo'
				... and dif96 >= 'umbral' and dif129 < 'umbralnegativo' and f012cola > tercio1
				etiquetatono$ = "H+L*"
				etiquetafinal$ = "H!H\% "
				etiquetatonoprofundo$ = "H+L*"
				etiquetafinalprofunda$ = "H!H\% "
				@ponetiqueta ()
	 
				@printData: "fórmula 9  H+L* H!H%"

			endif

			# después de h*
			if pitchaccent$= "H*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif96 >= 'umbralnegativo' and dif96 < 'umbral' and dif129 < 'umbralnegativo')
				etiquetatono$ = "H*"
				etiquetafinal$ = "HL\% "
				etiquetatonoprofundo$ = "H*"
				etiquetafinalprofunda$ = "HL\% "

				@ponetiqueta ()
					@printData: "fórmula 10 H* HL%"

			endif

			if pitchaccent$= "H*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif96 < 'umbralnegativo' and dif129 > 'umbral')
				etiquetatono$ = "H*"
				etiquetafinal$ = "LH\% "
				etiquetatonoprofundo$ = "H*"
				etiquetafinalprofunda$ = "LH\% "
				@ponetiqueta ()
				@printData: "fórmula 11 H* LH%"


			endif

			if pitchaccent$= "H*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif96 < 'umbralnegativo' and dif129 > 'umbral' and f012cola < tercio2)
				etiquetatono$ = "H*"
				etiquetafinal$ = "L!H\% "
				etiquetatonoprofundo$ = "H*"
				etiquetafinalprofunda$ = "L!H\% "

				@ponetiqueta ()
					@printData: "fórmula 12 H* L!H%"

			endif

			if pitchaccent$= "H*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif96 >= 'umbralnegativo' and dif96 < 'umbral' and dif129 < 'umbralnegativo' and f012cola >= tercio1)
				etiquetatono$ = "H*"
				etiquetafinal$ = "H!H\% "
				etiquetatonoprofundo$ = "H*"
				etiquetafinalprofunda$ = "H!H\% "

				@ponetiqueta ()
						@printData: "fórmula 13 H* H!H%"

			endif

			if pitchaccent$= "H*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and (dif96 >= 'umbral' and dif129 < 'umbralnegativo')
				etiquetatono$ = "H*"
				etiquetafinal$ = "\!dHL\% "
				etiquetatonoprofundo$ = "H*"
				etiquetafinalprofunda$ = "\!dHL\% "

				@ponetiqueta ()
							@printData: "fórmula 14 H*\!dHL%"

			endif

			if pitchaccent$= "H*" and ((difpre3 >= 'umbralnegativo') or (difpre3 < 'umbral'))
				... and ((dif96 >= 'umbral') and (dif129 < 'umbralnegativo') and (f012cola >= tercio1))
				etiquetatono$ = "H*"
				etiquetafinal$ = "\!dH!H\% "
				etiquetatonoprofundo$ = "H*"
				etiquetafinalprofunda$ = "\!dH!H\% "

				@ponetiqueta ()
				@printData: "fórmula 15 H* \!dH!H%"

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
					@printData: "16 L+H* LH%"

				@ponetiqueta ()
			endif

			if difpre3 >= umbral and dif96 < -1 and dif129 > 1 and durcola> 0.5
				etiquetatono$ = "L+H*"
				etiquetafinal$ = "H\% "
				etiquetatonoprofundo$ = "L+H*"
				etiquetafinalprofunda$ = "LH\% "
					@printData: "fórmula 16 L+H* LH%"

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
		if stressType > 0
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
			f06cola = Get value at time... 't6cola'-0.05
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
			dif6max = (12 / log10 (2)) * log10 ('f06cola' / 'f0maxton')
			dif0max3 = (12 / log10 (2)) * log10 ('f0maxprimeramitaddecola' / 'f00cola')
			dif0min3 = (12 / log10 (2)) * log10 ('f0minprimeramitaddecola' / 'f00cola')
			dif6min3 = (12 / log10 (2)) * log10 ('f06cola' / 'f0minprimeramitaddecola')
			
			@printData: "__ "
			@printData: "Diferecias tonema"
			@printData: "Diferencia de la tónica al final: " + fixed$(diftonfin, 2) + "semitonos."
			@printData: "Diferencia tónica- centro cola: " + fixed$(dif03, 2) + "semitonos."
			@printData: "Diferencia centro-final: " + fixed$(dif36, 2) + "semitonos."
			@printData: "Diferencia centro-máximo: " + fixed$(dif6max, 2) + "semitonos."


			
			etiquetafinal$= "final-no-agudo"
			etiquetafinalprofunda$="final-no-agudo"
			##########	monotonales después de L
			selectObject: myText
			numeropuntosahora = Get number of points: tier_Tones

			if (tonicaH = 0) and (diftonfin<'umbral')
				etiquetafinal$ = "L\% "
				etiquetafinalprofunda$ = "L\% "
				labelstressedprevious$ = Get label of point: tier_Tones, numeropuntosahora
				if labelstressedprevious$ = "(H+L*)+H" or labelstressedprevious$ = "H+(L*+H)"
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
				labelstressedprevious$ = Get label of point: tier_Tones, numeropuntosahora
				if labelstressedprevious$ = "(H+L*)+H" or labelstressedprevious$ = "H+(L*+H)"
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

			# subida en la 1poststressed y bajada en la segunda
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
				Insert point... 'deep_tier' 'endpointcola' 'etiquetafinalprofunda$'
			endif

			#acaba condicion de agudas o el resto
		endif
		# guardo para la proxima vez que pase que el inicio de la IP tiene que ser el final de la que acaba de pasar
		startIntervalIP = endIntervalIP
	endfor 
	#acaba el bucle para las IP 


	############## BREAK INDEX 3	##############

	if bI = 1
		etiquetafinal$ = " \O| "
		select TextGrid 'base$'
		numberOfPoints = Get number of points: tier_BI
		
		for i to numberOfPoints
			labeli$ = Get label of point: tier_BI, i
			if labeli$ = "3"
				timePoint = Get time of point: tier_BI, i
				posbreak = Get interval at time: segmentation_tier, timePoint
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

				startingtimeposbreak = Get start point... segmentation_tier 'posbreak'
				endingtimeposbreak = Get end point... 'segmentation_tier' 'posbreak'
				startingtimeprebreak = Get start point... segmentation_tier 'prebreak'
				endingtimeprebreak = Get end point... 'segmentation_tier' 'prebreak'

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
				label$ = Get label of interval... 'segmentation_tier' 'prebreak'
				for letra from 1 to numberOfLetras
					labeltext$[letra] = mid$ ("'label$'", letra)
				endfor
				#si es aguda
				if labeltext$[1] = marca_de_tonica$
					tonica = prebreak
					startingtimetonica = Get start point... 'segmentation_tier' 'tonica'
					endingtimetonica = Get end point... 'segmentation_tier' 'tonica'
					durtonica = endingtimetonica - startingtimetonica
					midstressed = startingtimetonica + (durtonica/2)

					select PitchTier 'base$'

					f01tonica = Get value at time... 'startingtimetonica'
 					f02tonica = Get value at time... 'midstressed'
					f03tonica = Get value at time... 'endingtimetonica'
					diftonbreak = (12 / log10 (2)) * log10 ('f03tonica' / 'f01tonica')

					if diftonbreak >= 'umbral' and f03tonica > f02tonica and f01posbreak > f03posbreak
						etiquetafinal$ = "H-"
					endif

				endif

				#comprobación lugar de llana
				select TextGrid 'base$'
				label$ = Get label of interval: segmentation_tier, preprebreak

				for letra from 1 to numberOfLetras
					labeltext$[letra] = mid$ ("'label$'", letra)
				endfor
				#si es llana
				if labeltext$[1] = marca_de_tonica$
					tonica = preprebreak
					startingtimetonica = Get start point... 'segmentation_tier' 'tonica'
					endingtimetonica = Get end point... 'segmentation_tier' 'tonica'
					durtonica = endingtimetonica - startingtimetonica
					midstressed = startingtimetonica + (durtonica/2)

					select PitchTier 'base$'

					f01tonica = Get value at time... 'startingtimetonica'
 					f02tonica = Get value at time... 'midstressed'
					f03tonica = Get value at time... 'endingtimetonica'

					diftonbreak = (12 / log10 (2)) * log10 ('f01posbreak' / 'f02tonica')

					if diftonbreak >= 'umbral' and f01posbreak > f03tonica and f01posbreak > f03posbreak
						etiquetafinal$ = "H-"
					endif


				endif

				#comprobación lugar de esdrújula
				select TextGrid 'base$'
				label$ = Get label of interval... 'segmentation_tier' 'prepreprebreak'
				for letra from 1 to numberOfLetras
					labeltext$[letra] = mid$ ("'label$'", letra)
				endfor
				#si es esdrujula
				if labeltext$[1] = marca_de_tonica$
					tonica = prepreprebreak
					poststressed = tonica + 1
					pospoststressed = tonica + 2
					startingtimetonica = Get start point... 'segmentation_tier' 'tonica'
					endingtimetonica = Get end point... 'segmentation_tier' 'tonica'
					durtonica = endingtimetonica - startingtimetonica
					midstressed = startingtimetonica + (durtonica/2)

					startingtimepoststressed = Get start point... 'segmentation_tier' 'poststressed'
					endingtimepoststressed = Get end point... 'segmentation_tier' 'poststressed'
					durpoststressed = endingtimepoststressed - startingtimepoststressed
					mediopoststressed = startingtimepoststressed + (durpoststressed/2)

					startingtimepospoststressed = Get start point... 'segmentation_tier' 'pospoststressed'
					endingtimepospoststressed = Get end point... 'segmentation_tier' 'pospoststressed'
					durpospoststressed = endingtimepospoststressed - startingtimepospoststressed
					mediopospoststressed = startingtimepospoststressed + (durpospoststressed/2)



					select PitchTier 'base$'
					f01tonica = Get value at time... 'startingtimetonica'
 					f02tonica = Get value at time... 'midstressed'
					f03tonica = Get value at time... 'endingtimetonica'

					f02poststressed = Get value at time... 'mediopoststressed'
					f02pospoststressed = Get value at time... 'mediopospoststressed'
					f03poststressed = Get value at time... 'endingtimepoststressed'

					diftonbreak = (12 / log10 (2)) * log10 ('f02pospoststressed' / 'f02tonica')

					if diftonbreak >= 'umbral' and f02pospoststressed > f02poststressed and f02pospoststressed > f03poststressed and f01posbreak > f03posbreak
						etiquetafinal$ = "H-"
					endif

				endif

				select TextGrid 'base$'
				Insert point... 'tier_Tones' 'timePoint' 'etiquetafinal$'
				Insert point... 'deep_tier' 'timePoint' 'etiquetafinal$'

			endif


		#acaba bucle de numero de fronteras
		

		endfor
	endif

	
	
##################		Tier normalizado		###############################################
if etiquetaje_normalizado = 1
	select TextGrid 'base$'
	numberOfTiers = Get number of tiers

	tier_standardization= deep_tier+1 
	Duplicate tier: deep_tier, tier_standardization, "Standardization"
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


################# borra el etiquetaje fonético en caso de que no se quiera y el normalizado

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
            deep_tier = itier
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

if debug = 0
	Save as text file: folder$ + "/"+ base$ + ".TextGrid"
endif

##############	CREAR FIGURAS		#####################
	if create_picture = 1
		picture_width = 7
		select Pitch 'base$'
		minpitch = do ("Get minimum...", 0, 0, "Hertz", "Parabolic")
		maxpitch = do ("Get maximum...", 0, 0, "Hertz", "Parabolic")
		gama = maxpitch - minpitch
		

		selectObject: mySound
		mySpectrogram= To Spectrogram... 0.005 5000 0.002 20 Gaussian
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
	removeObject: mySound, myText, myPitch, myPointProcess, intensity, intTable, stressedInventory
	

#############	FINAL BUCLE GENERAL	#############
# bucle archivos
endfor

# Limpieza final
select all
Remove

procedure ponetiqueta ()
	select TextGrid 'base$'
		Remove point... 'tier_Tones' 'pointfinal'
		Remove point... 'tier_Tones' 'pointultimastressed'

		Insert point... 'tier_Tones' 't3cola' 'etiquetatono$'
		Insert point... 'tier_Tones' 'endpointcola' 'etiquetafinal$'

	if etiquetaje_profundo =1
		Remove point... 'deep_tier' 'pointfinal'
		Remove point... 'deep_tier' 'pointultimastressed'
		Insert point... 'deep_tier' 't3cola' 'etiquetatonoprofundo$'
		Insert point... 'deep_tier' 'endpointcola' 'etiquetafinalprofunda$'
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


procedure printData: data$
	if verbose = 1
		appendInfoLine: data$
	endif
endproc

