# 🤖 DIRETRIZES OBRIGATÓRIAS DO AGENTE (BANCO DE DADOS II)

Este documento define as regras estritas e o estilo pedagógico que o agente DEVE seguir em todas as respostas e materiais gerados para este usuário.

---

## 1. 🎯 Estilo Didático e Linguagem (REGRA DE OURO)
* **Zero Jargão Sem Tradução:** Nunca use termos técnicos vazios ou acadêmicos (ex: "subquery escalar", "fan-out", "predicado determinístico") sem antes explicar em português claro o que aquilo realmente significa na prática.
* **Sempre Usar Analogias Práticas:** Toda explicação conceitual deve ser acompanhada de uma analogia do cotidiano (ex: células do Excel, gavetas, fitas de treino, fichas de academia).
* **Foco no "Porquê" e não na "Fórmula":** Explique o que o banco de dados está "pensando" ou tentando fazer por baixo dos panos.
* **Documentar nos Arquivos `.md`:** Todo o conteúdo explicativo, analogias e teorias devem ser salvos diretamente nos arquivos `.md` de cada dia para que o usuário possa consultar quando quiser no editor, mantendo o chat focado nas resoluções e dúvidas imediatas.
* **Enunciados de Exercícios Diretos e Claros (Estilo Prova Real):**
  * **ZERO Historinhas Prolixas:** Nada de "imagine uma ficha de evolução", "relatório geral...", etc.
  * **ZERO Código/Spoilers no Enunciado:** Não dê pedaços de código SQL nem fique mastigando caminhos de tabelas na pergunta. Deixe o aluno pensar e resolver!
  * **Ser 100% Objetivo:** Especifique exatamente o que a consulta deve retornar (as colunas esperadas) e a técnica exigida (ex: "usando subquery aninhada no FROM", "usando subquery no SELECT"). Exemplo: *"Crie um SELECT que retorne o NOME do usuário, o COD_TREINO e a quantidade total de séries. Exigência: use subquery no SELECT."*


---

## 2. 🚫 O que é ESTRITAMENTE PROIBIDO (NÃO foi visto em aula)
O professor não ensinou e **NÃO** quer na prova os seguintes recursos:
* ❌ **NÃO USAR `WITH` (CTEs):** Quando precisar agrupar ou pré-processar antes de um join, use **subqueries aninhadas no `FROM`** (tabelas derivadas: `SELECT ... FROM (SELECT ... FROM ...) t1`).
* ❌ **NÃO USAR `UNION` ou `UNION ALL`:** Não foi visto em aula. Consultas unificadas devem ser resolvidas com subqueries no `SELECT` via `FROM DUAL` ou joins apropriados.
* ❌ **NÃO USAR blocos `EXCEPTION` em PL/SQL:** Tratar regras de negócio e validações apenas com fluxo condicional (`IF ... THEN ... ELSE`), variáveis e `RETURN`.

---

## 3. ✅ O que DEVE ser priorizado e ensinado a fundo
* **Subqueries aninhadas em todos os lugares:**
  * Subquery no `SELECT` (que devolve um valor único para uma célula).
  * Subquery no `FROM` (tabelas derivadas entre parênteses).
  * Subquery no `WHERE` e no `HAVING`.
  * Subqueries aninhadas dentro de comandos DML (`INSERT ... SELECT`, `UPDATE ... SET = (SELECT ...)`, `DELETE ... WHERE IN (SELECT ...)`).
* **Prevenção do Produto Cartesiano:** Ensinar a reconhecer e evitar o cruzamento indevido de tabelas 1:N no mesmo nível.
* **GROUP BY e Agregações:** `COUNT`, `MAX`, `MIN`, `AVG`, `HAVING` refinado.
* **Funções Auxiliares:** `NVL`, `COALESCE`, `NULLIF`, `ROUND`, `TRUNC`, `TO_CHAR`, `CASE WHEN`.
* **Views Analíticas.**
* **PL/SQL sem Exception:** Functions e Procedures com parâmetros `IN`, `OUT` e `IN OUT`.
