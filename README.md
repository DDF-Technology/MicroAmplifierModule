# MicroAmplifierModule

Archivio tecnico e produttivo di un modulo micro-amplificatore basato sul circuito integrato
TDA2822. Il repository conserva i file consegnabili alla produzione e il materiale grafico
storico, senza ricostruire o modificare gli artefatti originali.

## Contenuto

- `BOM_PCB_MicroAmplifier_2022-04-06.csv`: distinta base;
- `PickAndPlace_PCB_MicroAmplifier_2022-04-06.csv`: coordinate di assemblaggio;
- `Gerber_PCB_MicroAmplifier_2022-04-06.zip`: strati Gerber e forature del PCB;
- `Piedinatura.png` e `MonoliticoBridge.png`: riferimenti tecnici;
- immagini e file PSD: materiali promozionali e di presentazione.

## Uso per la produzione

Prima di ordinare PCB o assemblaggio, estrarre il pacchetto Gerber in un visualizzatore dedicato
e verificare almeno outline, rame, solder mask, serigrafia, forature, stack-up e unità di misura.
Confrontare quindi distinta base e pick-and-place con disponibilità, package e orientamento dei
componenti. I file sono datati 6 aprile 2022 e potrebbero richiedere una revisione produttiva.

## Limiti e sicurezza

Il repository non documenta collaudo, alimentazione, prestazioni audio, dissipazione o conformità
del prodotto finito. La realizzazione hardware deve essere validata da personale competente prima
dell'impiego in apparecchiature reali.

## Proprietà e licenza

Copyright © 2026 Fabio De Deo — [www.ddf.technology](https://www.ddf.technology/). Tutti i
diritti riservati. Consultare [LICENSE](LICENSE).
