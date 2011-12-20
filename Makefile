DB=alchemy.sqlite
SQLITE=sqlite3
MAKEFILE=Makefile

RAW_INGREDIENTS_CSV=data/RAW.csv

RAW_EFFECTS_CSV=data/effects.csv

INGREDIENTS_CSV=data/ingredients.csv
INGREDIENTS_INDICES=$$1 "," $$2 "," $$7 "," $$8
INGREDIENTS_KEY=$$1

HASEFFECT_CSV=data/haseffect.csv
HASEFFECT_INDICES=\$$3 \$$4 \$$5 \$$6

CSVGENDBS=${INGREDIENTS_CSV} ${HASEFFECT_CSV}

CSVDBS=${RAW_EFFECTS_CSV} ${CSVGENDBS}

TABLES_LOAD=sql/tables.sql
TABLES_DROP=sql/drop.sql

$(DB): drop ${TABLES_LOAD} ${CSVDBS}
	${SQLITE} ${DB} < ${TABLES_LOAD}

drop: ${TABLES_DROP} force
	-bash -c '([[ -e ${DB} ]] && ${SQLITE} ${DB} < ${TABLES_DROP}) || [[ ! -e ${DB} ]]'

$(INGREDIENTS_CSV): $(RAW_INGREDIENTS_CSV)
	awk -F, '{print $(INGREDIENTS_INDICES)}' < ${RAW_INGREDIENTS_CSV} | tail -n +2 > $@

$(HASEFFECT_CSV): $(RAW_INGREDIENTS_CSV)
	rm -rf $@
	touch $@
	for i in ${HASEFFECT_INDICES}; do awk -F, "{print \${INGREDIENTS_KEY} \",\" $$i}" < ${RAW_INGREDIENTS_CSV} | tail -n +2 >> $@; done

clean:
	rm -rf ${CSVGENDBS}
	rm -rf ${DB}

force:
