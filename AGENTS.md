# 🤖 DIRETRIZES OBRIGATÓRIAS DO AGENTE (BANCO DE DADOS II — ORACLE SQL & PL/SQL)

Este documento define as regras estritas, as restrições da disciplina, o estilo pedagógico e o mapa completo de arquivos deste repositório para que qualquer agente (em qualquer computador) continue o trabalho exatamente com o mesmo padrão.

---

## 1. 🎯 Estilo Didático e Linguagem (REGRA DE OURO)
* **Zero Jargão Sem Tradução:** Nunca use termos técnicos vazios ou acadêmicos (ex: "subquery escalar", "fan-out", "predicado determinístico") sem antes explicar em português claro o que aquilo realmente significa na prática.
* **Sempre Usar Analogias Práticas:** Toda explicação conceitual deve ser acompanhada de uma analogia do cotidiano (ex: células do Excel, caixas de papelão lacradas, post-its, cadeira de 1 lugar, envelopes dos Correios).
* **Foco no "Porquê" e não na "Fórmula":** Explique o que o banco de dados está "pensando" ou tentando fazer por baixo dos panos.
* **Documentar nos Arquivos `.md`:** Todo o conteúdo explicativo, analogias, teorias e correções comentadas devem ser salvos diretamente nos arquivos `.md` para consulta offline/online.
* **Enunciados de Exercícios e Simulados (Estilo Prova Real):**
  * **Com Contexto Direto de Negócio:** Exemplo: *"Descobriu-se necessária a criação de uma Procedure capaz de..."*, *"Identificou-se a necessidade de..."*, *"Constatou-se que..."*.
  * **ZERO Código/Spoilers no Enunciado:** Não dê pedaços de código SQL nem entregue o caminho mastigado das tabelas na pergunta.
  * **Ignorar geração automática de `COD_` (`SUBSTR`/`LPAD`):** Nos exercícios novos de `INSERT`, passe o código textual (`P_COD_...`) diretamente como parâmetro de entrada, sem exigir malabarismos de `SUBSTR`/`LPAD`.

---

## 2. 🚫 O que é ESTRITAMENTE PROIBIDO (NÃO foi visto em aula)
O professor não ensinou e **NÃO** permite na prova os seguintes recursos:
* ❌ **NÃO USAR `WITH` (CTEs):** Quando precisar agrupar ou pré-processar antes de um join, use **subqueries aninhadas no `FROM`** (tabelas derivadas: `SELECT ... FROM (SELECT ... FROM ...) t1`) ou **subqueries no `SELECT`**.
* ❌ **NÃO USAR `UNION` ou `UNION ALL`:** Não foi visto em aula. Consultas unificadas em linha única devem ser resolvidas com subqueries no `SELECT` via `FROM DUAL` ou joins apropriados.
* ❌ **NÃO USAR blocos `EXCEPTION` em PL/SQL:** Tratar regras de negócio, nulos e validações apenas com fluxo condicional (`IF ... ELSIF ... ELSE`), `NVL`, `NULLIF`, variáveis locais e `RETURN`.
* ❌ **NÃO USAR cursores explícitos ou loops (`FOR / LOOP`) quando um comando em conjunto resolver:** O Oracle opera por conjuntos (ex: `UPDATE` chamando `FUNCTION` direto nas linhas da tabela).

---

## 3. ✅ O que DEVE ser priorizado e cobrado na prova
* **Subqueries aninhadas em todos os lugares:**
  * Subquery no `SELECT` (célula única; excelente para `COUNT` sem risco de produto cartesiano).
  * Subquery no `FROM` (post-it / tabela derivada entre parênteses, exigindo crachá `ID_` no `SELECT` e no `GROUP BY`).
  * Subquery no `WHERE` (filtro de elite para achar dono do maior/menor valor) e no `HAVING` (ex: `HAVING AVG(...) = (SELECT MAX(AVG(...)) ... GROUP BY ...)`).
  * Subqueries aninhadas dentro de comandos DML (`INSERT INTO ... SELECT`, `UPDATE ... SET = CASE WHEN (SELECT ...)`, `DELETE ... WHERE ID NOT IN (SELECT ID ... WHERE ID IS NOT NULL)`).
* **Prevenção do Produto Cartesiano:** Nunca cruzar duas tabelas filhas `1:N` (ex: `TRE_META`, `TRE_RECORD`, `TRE_SERIE`) soltas no mesmo nível e nunca separar tabelas/subqueries por vírgula no `FROM`.
* **Relacionamentos Indiretos / Temporais do Banco `TRE_`:**
  * `TRE_META` $\leftrightarrow$ `TRE_RECORD`: Mesmo `ID_USUARIO`, mesmo `ID_EXERCICIO` e `r.DATA_RECORD BETWEEN m.DATA_CRIACAO AND NVL(m.DATA_CONCLUSAO, SYSDATE)`.
  * `TRE_RECORD` $\leftrightarrow$ `TRE_SERIE`: Mesmo `ID_USUARIO`, `TRUNC(t.DATA_TREINO) = TRUNC(r.DATA_RECORD)`, mesmo `ID_EXERCICIO` em `TRE_ITEM_TREINO` e `s.CARGA = r.CARGA_RECORD`.
* **Funções Auxiliares:** `NVL` (obrigatório em `MAX`, `MIN`, `SUM`, `AVG` quando pode não haver linhas), `COALESCE`, `NULLIF` (proteção contra divisão por zero), `ROUND`, `TRUNC`, `CASE WHEN ... END` (no SQL) vs `CASE ... ELSE ... END CASE;` (no PL/SQL).
* **Views Analíticas (`CREATE OR REPLACE VIEW`).**
* **PL/SQL sem Exception:**
  * `PROCEDURE` e `FUNCTION` com parâmetros `IN`, `OUT` e `IN OUT` (variáveis obrigatórias na chamada de `OUT`/`IN OUT`).
  * Uso de `%TYPE` e `%ROWTYPE` (sempre com `SELECT * INTO v_rowtype`).
  * `SQL%ROWCOUNT` após comandos DML.
  * Padrão do `ATV_GRUPO.sql`: Procedure V1 (com subquery no `FROM` + `GROUP BY` + desempate `MIN(ID)`) $\rightarrow$ Function de contagem/cálculo por `COD_` $\rightarrow$ Procedure V2 consumindo a Function dentro da subquery do `FROM`.

---

## 4. 📂 Mapa Completo dos Arquivos no Repositório

1. **Scripts SQL Base, de Aula e Arsenal de Prova:**
   * `TRE_SCRIPT_DDL.sql`: Estrutura completa das 8 tabelas do sistema de treinos (`TRE_USUARIO`, `TRE_GRUPOMUSCULAR`, `TRE_EXERCICIO`, `TRE_META`, `TRE_RECORD`, `TRE_TREINO`, `TRE_ITEM_TREINO`, `TRE_SERIE`).
   * `TRE_SCRIPT_DML_CORRETO.sql`: Massa de dados oficial populada e validada.
   * `ATV_GRUPO.sql`: Script feito em grupo na aula (CRUDs em Procedures + `TREINO_MAX_SERIE`, `COUNT_SERIES_TREINO` e `TREINO_MAX_SERIE2`).
   * `ARSENAL_PROVA_TRE.sql`: Script completo com 8 Views Salva-Vidas (JOINs completos + SUM, AVG, MAX, MIN, COUNT), 8 Functions diretas no `SELECT`, 4 novos Trios de Procedures V1/V2 e CRUDs das 5 tabelas que faltavam no `ATV_GRUPO.sql`.
2. **Manuais de Estudo, Arsenal e Revisão Geral:**
   * `ARSENAL_PROVA_COMENTADO.md`: Mapa de bolso em tabela explicando todas as Views, Functions e Procedures do `ARSENAL_PROVA_TRE.sql` e como usá-las na prova.
   * `CONTEUDO_COMPLETO_BANCO2.md`: Enciclopédia unificada (~1.170 linhas) com toda a teoria, **Seção 1.8 (Guia Mestre Comparativo de Subqueries)**, diagramas ASCII, analogias e exemplos comentados dos 4 dias.
   * `GUIA_DE_DUVIDAS_E_PEGADINHAS.md`: Os 15 erros e armadilhas reais enfrentados pelo aluno durante os estudos, explicados com código errado vs código certo.
   * `LISTA_EXERCICIOS_REVISAO_RAPIDA.md`: 11 exercícios diretos por tópico + resoluções enviadas pelo aluno e código do `ATV_GRUPO.sql`.
3. **Simulados Finais de Prova:**
   * `SIMULADO_TEORICO.html`: 1º Simulado Teórico & Caça aos Bugs interativo em HTML (gabaritado 10/10 pelo aluno).
   * `SIMULADO_TEORICO_DOMINGO.html`: 2º Simulado Teórico & Caça aos Bugs interativo em HTML (focado nos ajustes finos e nas 4 questões do professor).
   * `SIMULADO_PRATICO_FINAL.md`: 1º Simulado Prático completo + script resolvido pelo aluno (9,1/10) com comentários inline detalhando cada acerto e ajuste fino.
   * `SIMULADO_PRATICO_DOMINGO.md`: 2º Simulado Prático completo + gabarito oficial 100% comentado no final para revisão rápida.
4. **Guias Diários Originais (Dias 1 a 4 + Cronograma):**
   * `CRONOGRAMA_ESTUDOS_5_DIAS.md`
   * `DIA_1_GUIA_E_EXERCICIOS.md`
   * `DIA_2_GUIA_E_EXERCICIOS.md`
   * `DIA_3_GUIA_E_EXERCICIOS.md`
   * `DIA_4_GUIA_E_EXERCICIOS.md`
5. **Prática Intensiva de Hoje (19/10/2026) — ONDE PARAMOS PARA CONTINUAR NO OUTRO PC:**
   * `PRATICA_SUBQUERIES_19_10.md` e `19 10 2026.sql`: Contêm os 5 exercícios de Subqueries resolvidos hoje pelo aluno (9,8/10), os 3 insights destravados (`HAVING` Espelho, Onde Mora Cada ID em `TRE_SERIE` e `BETWEEN` antes do `MAX` em `TRE_META` $\leftrightarrow$ `TRE_RECORD`), a Rodada Rápida de DML/Vigência Temporal (Exercício 2 já resolvido; faltam Exercícios 1 de `DELETE` e 3 de `UPDATE`), e **a próxima etapa combinada: praticar Procedures de Maior/Menor (Padrão Trio V1 / Function / V2)**.

