name=test17
combineCards.py cards_CR1_2017/*.txt cards_CR2_2017/*.txt cards_SR_2017/*.txt >& ${name}.txt

combine -M Significance --expectSignal=1 -t -1 ${name}.txt > result_${name}.txt
combine -M Significance --expectSignal=1 -t -1 ${name}.txt --freezeParameters all > result_freezeAll${name}.txt

text2workspace.py ${name}.txt -m 125
combineTool.py -M Impacts -d ${name}.root -t -1 --expectSignal=1 -m 125 --doInitialFit --robustFit 1
combineTool.py -M Impacts -d ${name}.root -t -1 --expectSignal=1 -m 125 --robustFit 1 --doFits --parallel 4
combineTool.py -M Impacts -d ${name}.root -t -1 --expectSignal=1 -m 125 -o impacts_${name}.json
plotImpacts.py -i impacts_${name}.json -o impacts_${name}