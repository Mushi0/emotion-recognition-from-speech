Read from file... \emotional-corpus\Emotions-praat-textgrid-collection\g-align.Collection
Read from file... \emotional-corpus\Emotions-praat-textgrid-collection\g-silence.Collection

echo PROGRAM STARTING
printline
maxIndex = 180

for index from 1 to maxIndex
	printline Processing file 'index'...
	

	selectObject: 'index'
	numberOfIntervals = Get number of intervals... 3

	wavname$ = selected$()
	if mid$(wavname$, 14, 2) = "si"
		wavname$ = right$(wavname$, 7)
	else
		wavname$ = right$(wavname$, 6)
	endif
	filename$ = "/emotional-corpus/Emotions-speech/" + wavname$ + ".wav"
	wave = Read from file... 'filename$'
	
	
	# create a table to save the data
	
	table = Create TableOfReal... 'wavname$' numberOfIntervals 9

	
	selectObject : 'index' + 180
	
	silenceIntervals = Get number of intervals... 1
	
	ii = 1;
	for kk from 1 to silenceIntervals
		start = Get start point... 1 'kk'
		end = Get end point... 1 'kk'
		label$ = Get label of interval... 1 'kk'
		if label$ = "silent"
			silenceStart[ii] = start
			silenceEnd[ii] = end
			ii = ii + 1
		endif
	endfor
	
	# actual number of intervals for silence
	silenceIntervals = ii-1
	
	# create all the objects you need (pitch, intensity, formants, harmonicity)
	selectObject: "Sound " + wavname$
	pitchObj = To Pitch... 0 75 600
	selectObject: "Sound " + wavname$
	intensityObj = To Intensity... 100 0 Subtract mean
	selectObject: "Sound " + wavname$
	formantObj = To Formant (burg)... 0 5 5500 0.025 50
	selectObject: "Sound " + wavname$
	harmonicityObj = To Harmonicity (cc)... 0.01 75 0.1 1.0
	
	
	for intervalNumber from 1 to numberOfIntervals
		selectObject: index
		startTime[intervalNumber] = Get start point... 3 'intervalNumber'
		endTime[intervalNumber] = Get end point... 3 'intervalNumber'
		text$ = Get label of interval... 3 'intervalNumber'
		
		selectObject: table
		Set row label (index)... 'intervalNumber' 'text$'
		
		# check if start and end times overlap with silence
		
		selectObject: index
		
		for kk from 1 to silenceIntervals
			if startTime[intervalNumber] >= silenceStart[kk] and startTime[intervalNumber] <= silenceEnd[kk]
				startTime[intervalNumber] = silenceEnd[kk]
			endif
			if endTime[intervalNumber] >= silenceStart[kk] and endTime[intervalNumber] <= silenceEnd[kk]
				endTime[intervalNumber] = silenceStart[kk]
			endif
		endfor
		
		selectObject: pitchObj
		st = startTime[intervalNumber]
		en = endTime[intervalNumber]
		meanPitch[intervalNumber] = Get mean... 'st' 'en' Hertz
		if meanPitch[intervalNumber] = undefined
			meanPitch[intervalNumber] = -1
		endif
		
		
		selectObject: intensityObj
		meanIntensity[intervalNumber] = Get mean... 'st' 'en' dB
		if meanIntensity[intervalNumber] = undefined
			meanIntensity[intervalNumber] = -1
		endif
		
		selectObject: formantObj
		meanF1[intervalNumber] = Get mean... 1 'st' 'en' Hertz
		meanF2[intervalNumber] = Get mean... 2 'st' 'en' Hertz
		if meanF1[intervalNumber] = undefined
			meanF1[intervalNumber] = -1
		endif
		if meanF2[intervalNumber] = undefined
			meanF2[intervalNumber] = -1
		endif
		
		selectObject: harmonicityObj
		harmonicity[intervalNumber] = Get mean... 'st' 'en'
		if harmonicity[intervalNumber] = undefined
			harmonicity[intervalNumber] = -1
		endif
			
	endfor
	
	# deltas
	for intervalNumber from 1 to numberOfIntervals
		if intervalNumber = 1
			deltaPitch[intervalNumber] = meanPitch[intervalNumber+1] / (endTime[intervalNumber] - startTime[intervalNumber])
			deltaIntensity[intervalNumber] = meanIntensity[intervalNumber+1] / (endTime[intervalNumber] - startTime[intervalNumber])
			deltaF1[intervalNumber] = meanF1[intervalNumber+1] / (endTime[intervalNumber] - startTime[intervalNumber])
			deltaF2[intervalNumber] = meanF2[intervalNumber+1] / (endTime[intervalNumber] - startTime[intervalNumber])
		elsif intervalNumber = numberOfIntervals
			deltaPitch[intervalNumber] = -meanPitch[intervalNumber-1] / (endTime[intervalNumber] - startTime[intervalNumber])
			deltaIntensity[intervalNumber] = -meanIntensity[intervalNumber-1] / (endTime[intervalNumber] - startTime[intervalNumber])
			deltaF1[intervalNumber] = -meanF1[intervalNumber-1] / (endTime[intervalNumber] - startTime[intervalNumber])
			deltaF2[intervalNumber] = -meanF2[intervalNumber-1] / (endTime[intervalNumber] - startTime[intervalNumber])
		else
			deltaPitch[intervalNumber] = (meanPitch[intervalNumber+1]-meanPitch[intervalNumber-1]) / (endTime[intervalNumber] - startTime[intervalNumber])
			deltaIntensity[intervalNumber] = (meanIntensity[intervalNumber+1] -meanIntensity[intervalNumber-1]) / (endTime[intervalNumber] - startTime[intervalNumber])
			deltaF1[intervalNumber] = (meanF1[intervalNumber+1]-meanF1[intervalNumber-1]) / (endTime[intervalNumber] - startTime[intervalNumber])
			deltaF2[intervalNumber] = (meanF2[intervalNumber+1]-meanF2[intervalNumber-1]) / (endTime[intervalNumber] - startTime[intervalNumber])
		endif
		
	endfor
	
	selectObject: table

	for intervalNumber from 1 to numberOfIntervals
		st = startTime[intervalNumber]
		en = endTime[intervalNumber]
		avP = meanPitch[intervalNumber]
		dP = deltaPitch[intervalNumber]
		avI = meanIntensity[intervalNumber]
		dI = deltaIntensity[intervalNumber]
		f1 = meanF1[intervalNumber]
		f2 = meanF2[intervalNumber]
		dF1 = deltaF1[intervalNumber]
		dF2 = deltaF2[intervalNumber]
		h = harmonicity[intervalNumber]
		printline Token 'intervalNumber' : 'st's to 'en's; pitch = 'avP'; delta pitch = 'dP'; intensity = 'avI'; delta int = 'dI'; F1 = 'f1'; dF1 = 'dF1'; F2 = 'f2'; dF2 = 'dF2'; harmonicity = 'h'
		
		# populate the table
		Set value... 'intervalNumber' 1 'avP'
		Set value... 'intervalNumber' 2 'dP'
		Set value... 'intervalNumber' 3 'avI'
		Set value... 'intervalNumber' 4 'dI'
		Set value... 'intervalNumber' 5 'f1'
		Set value... 'intervalNumber' 6 'dF1'
		Set value... 'intervalNumber' 7 'f2'
		Set value... 'intervalNumber' 8 'dF2'
		Set value... 'intervalNumber' 9 'h'

		Set column label (index)...  1 avP
		Set column label (index)...  2 dP
		Set column label (index)...  3 avI
		Set column label (index)...  4 dI
		Set column label (index)...  5 f1
		Set column label (index)...  6 dF1
		Set column label (index)...  7 f2
		Set column label (index)...  8 dF2
		Set column label (index)...  9 h

		
	endfor
	

	selectObject: table
	filename$ = "features for matlab/" + wavname$ + ".txt"
	Save as headerless spreadsheet file... 'filename$'
	
	printline Done!
	printline
endfor


# normalisation 
for index from 1 to maxIndex
	# la categorizzazione fra low mid high dovrebbe essere fatta in base all'area sottesa dalla "curva"
	# per questioni di outliers 
	# se semplicemente suddividiamo un segmento in tre parti uguali, sbagliamo nel caso 10, 14, 15, 13, 6000 (per colpa di un outlier perdiamo risoluzione nell'effettivo range che va da 10 a 20, ad es)
	# con la mediana non funziona neppuer in quanto 10, 11, 11, 11, 11, 50 suddivide (10,11) (11,11), (11,50) ma noi vogliamo che gli stessi valori appartengano alla stessa classe
	# la cosa migliore è utilizzare il metodo dell'area (come?)
	
	

endfor