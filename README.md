# 🏋️ Estudos de Banco de Dados II (Oracle SQL & PL/SQL) — Sistema `TRE_`

Repositório completo de preparação para a prova de **Banco de Dados II**, contendo o banco de dados oficial (`TRE_`), enciclopédia teórica completa, guia de pegadinhas, listas de exercícios resolvidos e simulados práticos e teóricos.

---

## 🚫 Regras Estritas da Prova (Lembrete Rápido)
- ❌ **Proibido `WITH` (CTEs):** Usar subqueries aninhadas no `FROM` ou no `SELECT`.
- ❌ **Proibido `UNION` / `UNION ALL`:** Usar subqueries no `SELECT` com `FROM DUAL` ou `JOIN`s.
- ❌ **Proibido Bloco `EXCEPTION` em PL/SQL:** Tratar validações com `IF / ELSIF / ELSE`, `NVL`, `NULLIF` e variáveis.

---

## 📚 Índice Rápido para Revisão (Ordem Recomendada)

### 1. 🛡️ Arsenal Salva-Vidas para a Prova (NOVO!)
- **[ARSENAL_PROVA_COMENTADO.md](./ARSENAL_PROVA_COMENTADO.md):** Mapa de bolso com todas as **8 Views**, **8 Functions** e **22 Procedures** prontas para usar ou copiar na prova.
- **[ARSENAL_PROVA_TRE.sql](./ARSENAL_PROVA_TRE.sql):** Script `.sql` pronto para rodar com `F5` no SQL Developer (já cria todas as Views com JOINs/SUM/AVG/MAX/MIN, Functions diretas no `SELECT`, os 5 Trios V1/V2 do professor e os CRUDs de todas as tabelas).

### 2. 🚨 Revisão Express antes da Prova
- **[GUIA_DE_DUVIDAS_E_PEGADINHAS.md](./GUIA_DE_DUVIDAS_E_PEGADINHAS.md):** Os **15 erros e armadilhas reais** mapeados durante a semana (código errado vs. código certo comentado).
- **[CONTEUDO_COMPLETO_BANCO2.md](./CONTEUDO_COMPLETO_BANCO2.md):** Enciclopédia completa com 100% da teoria, **Seção 1.8 (Guia Mestre Comparativo de Subqueries)**, diagramas ASCII, analogias e exemplos comentados de SQL e PL/SQL.

### 3. 🏆 Simulados de Prova (Com Resoluções e Gabaritos Comentados)
- **[SIMULADO_PRATICO_FINAL.md](./SIMULADO_PRATICO_FINAL.md):** 1º Simulado Prático + **Script do aluno corrigido e comentado linha a linha**.
- **[SIMULADO_PRATICO_DOMINGO.md](./SIMULADO_PRATICO_DOMINGO.md):** 2º Simulado Prático + **Gabarito Oficial 100% comentado no final**.
- **[SIMULADO_TEORICO.html](./SIMULADO_TEORICO.html):** 1º Simulado Teórico e Caça aos Bugs interativo.
- **[SIMULADO_TEORICO_DOMINGO.html](./SIMULADO_TEORICO_DOMINGO.html):** 2º Simulado Teórico e Caça aos Bugs interativo.

### 3. ⚡ Exercícios e Scripts SQL
- **[LISTA_EXERCICIOS_REVISAO_RAPIDA.md](./LISTA_EXERCICIOS_REVISAO_RAPIDA.md):** Exercícios rápidos por tópico + resoluções do aluno + código do `ATV_GRUPO.sql`.
- **[ATV_GRUPO.sql](./ATV_GRUPO.sql):** Script das atividades em grupo feitas em aula (Procedures de CRUD + `TREINO_MAX_SERIE` V1, Function `COUNT_SERIES_TREINO` e `TREINO_MAX_SERIE2` V2).
- **[TRE_SCRIPT_DDL.sql](./TRE_SCRIPT_DDL.sql):** Script `CREATE TABLE` de todas as 8 tabelas do banco `TRE_`.
- **[TRE_SCRIPT_DML_CORRETO.sql](./TRE_SCRIPT_DML_CORRETO.sql):** Script `INSERT` com todos os dados de teste do banco `TRE_`.

### 4. 📅 Guias Diários (Dias 1 a 4 + Resoluções)
- **[CRONOGRAMA_ESTUDOS_5_DIAS.md](./CRONOGRAMA_ESTUDOS_5_DIAS.md)**
- **[DIA_1_GUIA_E_EXERCICIOS.md](./DIA_1_GUIA_E_EXERCICIOS.md):** Anti-Produto Cartesiano, Subqueries no `SELECT`/`FROM`, `DUAL`, `NVL`, `COALESCE`.
- **[DIA_2_GUIA_E_EXERCICIOS.md](./DIA_2_GUIA_E_EXERCICIOS.md):** `GROUP BY`, `WHERE` vs `HAVING`, Donos de Maior/Menor Valor, `ROUND`, `NULLIF` e `VIEW`s.
- **[DIA_3_GUIA_E_EXERCICIOS.md](./DIA_3_GUIA_E_EXERCICIOS.md):** `PROCEDURE`s (`IN`, `OUT`, `IN OUT`), DML com Subqueries (`INSERT`, `UPDATE`, `DELETE` com `NOT IN`) e `SQL%ROWCOUNT`.
- **[DIA_4_GUIA_E_EXERCICIOS.md](./DIA_4_GUIA_E_EXERCICIOS.md):** `FUNCTION`s no `SELECT`, `%ROWTYPE`, Vigência Temporal (`Meta x Recorde x Série`) e Modularização.

---

## 🤖 Para Continuar em Outro Computador
O arquivo **[AGENTS.md](./AGENTS.md)** na raiz do repositório já contém todas as instruções, restrições do professor e contexto do projeto para qualquer assistente de IA continuar exatamente de onde paramos.
