# 🏆 SIMULADO PRÁTICO FINAL — BANCO DE DADOS II (FASE 2)

> **Instruções de Prova:**
> - Resolva as 5 questões abaixo diretamente no seu **Oracle SQL Developer** conectado ao banco `TRE_`.
> - **Restrições Obrigatórias da Disciplina:**
>   - ❌ **Proibido** usar `WITH` (CTEs) — utilize subqueries aninhadas quando necessário.
>   - ❌ **Proibido** usar `UNION` ou `UNION ALL`.
>   - ❌ **Proibido** usar blocos `EXCEPTION` em PL/SQL — trate validações com `IF / ELSIF / ELSE`, `NVL` e variáveis.
> - Ao finalizar, cole todo o seu script SQL/PLSQL no chat para correção e nota final!

---

## 📋 Questão 1 — Relatório Gerencial de Usuários (2,0 pontos)

Identificou-se a necessidade de gerar um relatório gerencial contendo todos os usuários cadastrados no sistema (`TRE_USUARIO`), exibindo:
- O código do usuário (`COD_USUARIO`);
- O nome do usuário (`NOME`);
- A quantidade total de metas cadastradas por ele (`TOTAL_METAS`);
- A quantidade total de recordes batidos por ele (`TOTAL_RECORDES`);
- A maior carga já levantada por ele em uma série de treino (`MAIOR_CARGA_SERIE`, baseada na coluna `CARGA` da tabela `TRE_SERIE`).

**Requisitos:**
- A consulta não pode gerar multiplicação indevida de linhas (produto cartesiano) entre metas, recordes e séries.
- Usuários que não possuam metas, recordes ou séries registradas devem aparecer normalmente na listagem exibindo o valor `0` nas respectivas colunas numéricas.

---

## 📋 Questão 2 — View de Auditoria de Metas na Vigência (2,0 pontos)

Descobriu-se necessária a criação de uma View chamada `VW_AUDITORIA_METAS` capaz de auditar o desempenho de todas as metas cadastradas na tabela `TRE_META`. A View deve exibir:
- O código da meta (`COD_META`);
- O nome do usuário dono da meta (`NOME_USUARIO`);
- O nome do exercício vinculado à meta (`NOME_EXERCICIO`);
- A carga-alvo da meta (`CARGA_ALVO`);
- O maior recorde (`MAIOR_RECORD_VIGENCIA`, baseado em `CARGA_RECORD` de `TRE_RECORD`) registrado por esse mesmo usuário e para esse mesmo exercício **estritamente dentro do período de vigência da meta** (entre `DATA_CRIACAO` e `DATA_CONCLUSAO`, considerando a data atual do sistema `SYSDATE` caso `DATA_CONCLUSAO` seja nula, ou `0` caso não haja nenhum recorde no período);
- Uma coluna calculada chamada `SITUACAO_AUDITORIA` que exiba:
  - `'META SUPERADA NO PRAZO'` quando o maior recorde registrado na vigência for maior ou igual à `CARGA_ALVO`;
  - `'EM EVOLUCAO'` quando houver recorde registrado na vigência, porém inferior à `CARGA_ALVO`;
  - `'SEM RECORDE NA VIGENCIA'` quando não houver nenhum recorde registrado no período de vigência.

**Requisitos:**
- Após o comando `CREATE OR REPLACE VIEW VW_AUDITORIA_METAS AS ...`, escreva também um `SELECT * FROM VW_AUDITORIA_METAS;` para consultar o resultado.

---

## 📋 Questão 3 — Fechamento Automático de Metas Atingidas (2,0 pontos)

Constatou-se que algumas metas que ainda constam com o status `'ATIVA'` na tabela `TRE_META` já tiveram sua `CARGA_ALVO` alcançada ou superada pelos usuários na tabela de histórico de recordes (`TRE_RECORD`).

Elabore um único comando `UPDATE` na tabela `TRE_META` que:
- Altere a coluna `STATUS` para `'CONCLUIDA'`;
- Preencha a coluna `DATA_CONCLUSAO` com a data atual do sistema (`SYSDATE`);
- Aplique essa alteração **apenas** para as metas que estejam atualmente com `STATUS = 'ATIVA'` e cujo usuário já possua, para o mesmo exercício da meta, algum registro na tabela `TRE_RECORD` com `CARGA_RECORD` maior ou igual à `CARGA_ALVO` da meta.

---

## 📋 Questão 4 — Procedure de Cadastro de Meta por Código (2,0 pontos)

Descobriu-se necessária a criação de uma Procedure chamada `PRC_CADASTRAR_META_POR_CODIGO` para registrar uma nova meta na tabela `TRE_META` utilizando os códigos textuais das entidades (`COD_`), sem que a aplicação externa precise informar os IDs numéricos internos.

**Especificações da Procedure:**
1. **Parâmetros:**
   - `P_COD_USUARIO` (entrada): código textual do usuário (ex: `'USR-001'`);
   - `P_COD_EXERCICIO` (entrada): código textual do exercício (ex: `'EXC-001'`);
   - `P_COD_META` (entrada): código textual da nova meta que será gravada (ex: `'META-099'`);
   - `P_CARGA_ALVO` (entrada): valor numérico da carga-alvo;
   - `P_DATA_ALVO` (entrada): data limite planejada para a meta;
   - `P_MENSAGEM` (saída — `OUT VARCHAR2`): texto informativo do resultado da operação.
2. **Regras de Negócio:**
   - A Procedure deve validar se `P_CARGA_ALVO` é maior que zero. Caso seja menor ou igual a zero (`<= 0`), **não** deve realizar o `INSERT` e deve preencher `P_MENSAGEM` com `'ERRO: CARGA ALVO INVALIDA'`.
   - Caso a carga-alvo seja válida (`> 0`), a Procedure deve consultar e armazenar em variáveis internas o `ID_USUARIO` e o `ID_EXERCICIO` correspondentes aos códigos recebidos, realizar o `INSERT` na tabela `TRE_META` preenchendo `DATA_CRIACAO` com `SYSDATE`, `DATA_CONCLUSAO` com `NULL` e `STATUS` com `'ATIVA'`, e preencher `P_MENSAGEM` com `'META CADASTRADA COM SUCESSO'`.
3. **Teste:**
   - Escreva um bloco anônimo (`DECLARE ... BEGIN ... END;`) que chame a Procedure `PRC_CADASTRAR_META_POR_CODIGO` passando dados válidos para um usuário e exercício existentes no banco e imprima o conteúdo de `P_MENSAGEM` no console via `DBMS_OUTPUT.PUT_LINE`.

---

## 📋 Questão 5 — Cálculo de Volume de Treino e Descoberta do Maior Treino (2,0 pontos)

### Parte A — Function `FNC_VOLUME_TOTAL_TREINO` (1,0 ponto)
Identificou-se a necessidade de criar uma Function chamada `FNC_VOLUME_TOTAL_TREINO` que receba como parâmetro o código textual de um treino (`P_COD_TREINO VARCHAR2`) e retorne o volume total de carga movimentado naquela sessão de treino.
- O volume total de um treino é dado pela soma da multiplicação de repetições por carga (`SUM(REPETICOES * CARGA)`) de todas as séries (`TRE_SERIE`) pertencentes aos itens daquele treino (`TRE_ITEM_TREINO`).
- Caso o treino não possua séries registradas, a função deve retornar `0`.
- Escreva também uma consulta `SELECT` na tabela `TRE_TREINO` que utilize a função `FNC_VOLUME_TOTAL_TREINO` para exibir `COD_TREINO`, `DATA_TREINO` e o volume total de cada treino.

### Parte B — Procedure `PRC_TREINO_MAIOR_VOLUME` (1,0 ponto)
Em seguida, descobriu-se necessária a criação de uma Procedure chamada `PRC_TREINO_MAIOR_VOLUME` (sem parâmetros) capaz de identificar e exibir no console (`DBMS_OUTPUT.PUT_LINE`), utilizando **obrigatoriamente** a função `FNC_VOLUME_TOTAL_TREINO` criada na Parte A:
- O valor do maior volume total registrado entre todos os treinos do sistema;
- O `ID_TREINO` correspondente a esse maior volume (em caso de empate entre dois ou mais treinos, deve capturar o menor `ID_TREINO`);
- O `COD_TREINO` desse treino vencedor.
- Ao final, escreva o comando para executar a Procedure.
