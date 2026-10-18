# 🏆 2º SIMULADO PRÁTICO (EDIÇÃO DE DOMINGO) — BANCO `TRE_`

> **Instruções de Prova:**
> - Todas as 5 questões abaixo foram projetadas e validadas para o seu banco oficial **`TRE_`** (`TRE_SCRIPT_DDL.sql` e `TRE_SCRIPT_DML_CORRETO.sql`).
> - **Restrições Obrigatórias da Disciplina:**
>   - ❌ **Proibido** usar `WITH` (CTEs) — utilize subqueries aninhadas quando necessário.
>   - ❌ **Proibido** usar `UNION` ou `UNION ALL`.
>   - ❌ **Proibido** usar blocos `EXCEPTION` em PL/SQL — trate validações com `IF / ELSIF / ELSE`, `NVL` e variáveis.
> - Ao finalizar no SQL Developer, cole todo o seu script aqui no chat para correção comentada!

---

## 📋 Questão 1 — Extremos Globais e Extremos por Categoria (2,0 pontos)

### Parte A — Usuário com a Maior Média Geral de Carga (1,0 ponto)
Identificou-se a necessidade de descobrir qual usuário possui a **maior média geral de carga** considerando todas as séries executadas no sistema (`TRE_SERIE`). Elabore uma consulta `SELECT` que exiba:
- O identificador do usuário (`ID_USUARIO`);
- O nome do usuário (`NOME`);
- A média geral de carga arredondada em 2 casas decimais (`MEDIA_GERAL_CARGA`);
- A maior carga individual já levantada por esse usuário em uma série (`MAIOR_CARGA_USUARIO`).

### Parte B — Maior e Menor Recorde por Grupo Muscular (1,0 ponto)
Identificou-se também a necessidade de gerar um relatório comparativo por grupo muscular (`TRE_GRUPOMUSCULAR`) com base na tabela de recordes (`TRE_RECORD`). Elabore uma consulta `SELECT` utilizando subqueries aninhadas no `FROM` que exiba, em uma mesma linha para cada grupo muscular:
- O nome do grupo muscular (`NOME_GRUPO`);
- O nome do exercício que detém o **maior recorde** daquele grupo (`EXERCICIO_MAIOR_REC`);
- O valor desse maior recorde (`MAIOR_RECORD`);
- O nome do exercício que detém o **menor recorde** daquele grupo (`EXERCICIO_MENOR_REC`);
- O valor desse menor recorde (`MENOR_RECORD`).

---

## 📋 Questão 2 — View de Raio-X dos Exercícios (2,0 pontos)

Descobriu-se necessária a criação de uma View chamada `VW_RAIO_X_EXERCICIOS` contendo **todos** os exercícios cadastrados na tabela `TRE_EXERCICIO` (inclusive aqueles que nunca foram executados em séries ou que não possuem recordes registrados).

A View deve exibir:
- O código do exercício (`COD_EXERCICIO`);
- O nome do exercício (`NOME_EXERCICIO`);
- O tipo de autoria do exercício (`TIPO_EXERCICIO`): exibindo `'PERSONALIZADO'` quando a coluna `ID_USUARIO` da tabela `TRE_EXERCICIO` estiver preenchida (`IS NOT NULL`), ou `'GLOBAL'` quando for nula (`IS NULL`);
- A quantidade total de séries já realizadas para esse exercício em `TRE_SERIE` (`TOTAL_SERIES`), exibindo `0` caso nunca tenha sido executado;
- O valor do maior recorde já registrado para esse exercício em `TRE_RECORD` (`MAIOR_RECORDE`), exibindo `0` caso não possua recordes;
- Uma coluna calculada chamada `NIVEL_CARGA` (construída diretamente no `SELECT` da View, sem criar Function auxiliar) que exiba:
  - `'PESADO'` quando o `MAIOR_RECORDE` for maior ou igual a `100`;
  - `'MODERADO'` quando o `MAIOR_RECORDE` for maior que `0` e menor que `100`;
  - `'SEM HISTORICO'` quando o `MAIOR_RECORDE` for igual a `0`.

**Requisitos:**
- A View não pode gerar multiplicação indevida de linhas (produto cartesiano) entre séries e recordes e não pode duplicar exercícios.
- Ao final, escreva `SELECT * FROM VW_RAIO_X_EXERCICIOS;` para exibir o resultado.

---

## 📋 Questão 3 — Atualização em Lote e Exclusão Segura com Subqueries (2,0 pontos)

### Parte A — Padronização de Observações de Treino via `UPDATE` (1,0 ponto)
Constatou-se a necessidade de padronizar a coluna `OBSERVACOES` de todos os registros da tabela `TRE_TREINO` de acordo com a quantidade de exercícios (`TRE_ITEM_TREINO`) realizados em cada sessão. Elabore um único comando `UPDATE` na tabela `TRE_TREINO` (utilizando `CASE WHEN` e subquery correlacionada) que preencha `OBSERVACOES` com:
- `'TREINO COMPLETO'` quando o treino possuir **3 ou mais** itens vinculados em `TRE_ITEM_TREINO`;
- `'TREINO RAPIDO'` quando o treino possuir **1 ou 2** itens vinculados em `TRE_ITEM_TREINO`;
- `'TREINO VAZIO'` quando o treino não possuir **nenhum** item vinculado (`0`).

### Parte B — Limpeza de Exercícios Nunca Utilizados via `DELETE` (1,0 ponto)
Constatou-se que alguns exercícios cadastrados na tabela `TRE_EXERCICIO` jamais foram utilizados no sistema. Elabore um único comando `DELETE` na tabela `TRE_EXERCICIO` utilizando `NOT IN` (com a devida proteção contra valores nulos) que apague apenas os exercícios que **não** estejam presentes em `TRE_ITEM_TREINO`, **não** estejam presentes em `TRE_META` e **não** estejam presentes em `TRE_RECORD`.

---

## 📋 Questão 4 — Procedure de Revisão de Série com Saneamento `IN OUT` (2,0 pontos)

Descobriu-se necessária a criação de uma Procedure chamada `PRC_REVISAR_CARGA_SERIE` para atualizar a carga e as repetições de uma série específica na tabela `TRE_SERIE` a partir do seu código textual (`COD_SERIE`).

**Especificações da Procedure:**
1. **Parâmetros:**
   - `P_COD_SERIE` (entrada — `IN`): código textual da série (ex: `'SER-001'`);
   - `P_NOVA_CARGA` (entrada e saída — `IN OUT`): novo valor de carga proposto;
   - `P_NOVAS_REPETICOES` (entrada e saída — `IN OUT`): nova quantidade de repetições proposta;
   - `P_RESULTADO` (saída — `OUT VARCHAR2`): mensagem de status da gravação.
2. **Regras de Negócio:**
   - **Saneamento:** Caso `P_NOVA_CARGA` seja menor que `5`, a Procedure deve corrigir o valor do próprio parâmetro para `5`. Caso `P_NOVAS_REPETICOES` seja menor que `1`, deve corrigir o valor do parâmetro para `1`.
   - **Atualização:** Executar um `UPDATE` na tabela `TRE_SERIE` alterando `CARGA` e `REPETICOES` para os valores já saneados onde `COD_SERIE = P_COD_SERIE`.
   - **Retorno de Status:** Verificar com `SQL%ROWCOUNT` se o `UPDATE` alterou alguma linha. Se alterou (`>= 1`), preencher `P_RESULTADO` com `'SERIE ATUALIZADA COM SUCESSO'`; caso contrário (`0`), preencher com `'ERRO: SERIE NAO ENCONTRADA'`.
3. **Teste:**
   - Escreva um bloco anônimo (`DECLARE ... BEGIN ... END;`) que teste a Procedure passando `'SER-001'`, uma carga `0` (para testar o saneamento) e repetições `10`, imprimindo ao final o `P_RESULTADO` e o valor corrigido da variável de carga no console.

---

## 📋 Questão 5 — Function com `%ROWTYPE` + Procedure do Exercício Mais Praticado (2,0 pontos)

### Parte A — Function `FNC_QTD_SERIES_EXERCICIO` (1,0 ponto)
Identificou-se a necessidade de criar uma Function chamada `FNC_QTD_SERIES_EXERCICIO` que receba como parâmetro o código textual de um exercício (`P_COD_EXERCICIO VARCHAR2`) e retorne (`RETURN NUMBER`) a quantidade total de séries (`TRE_SERIE`) já realizadas para aquele exercício em todo o banco.
- **Requisito obrigatório:** Dentro da Function, declare uma variável utilizando **`TRE_EXERCICIO%ROWTYPE`**, carregue a linha completa do exercício correspondente ao `P_COD_EXERCICIO` nessa variável e utilize o campo `ID_EXERCICIO` dessa variável para contar as séries vinculadas.
- Escreva também um `SELECT` na tabela `TRE_EXERCICIO` exibindo `COD_EXERCICIO`, `NOME` e o retorno da Function.

### Parte B — Procedure `PRC_EXERCICIO_MAIS_PRATICADO` (1,0 ponto)
Em seguida, descobriu-se necessária a criação de uma Procedure chamada `PRC_EXERCICIO_MAIS_PRATICADO` (sem parâmetros) capaz de identificar e exibir no console (`DBMS_OUTPUT.PUT_LINE`), utilizando **obrigatoriamente** a função `FNC_QTD_SERIES_EXERCICIO` criada na Parte A:
- A maior quantidade de séries realizadas em um único exercício no sistema;
- O `ID_EXERCICIO` vencedor (em caso de empate, o menor `ID_EXERCICIO`);
- O `NOME` desse exercício vencedor.
- Ao final, escreva o comando para executar a Procedure.
