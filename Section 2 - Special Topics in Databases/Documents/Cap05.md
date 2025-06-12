# Usuários, Grupos e Permissões no PostgreSQL

## Introdução

O PostgreSQL implementa um sistema robusto de controle de acesso baseado em usuários (roles) e permissões. Este sistema permite controlar quem pode acessar o banco de dados, quais operações podem ser executadas e em quais objetos do banco.

## Conceitos Fundamentais

### Roles (Funções)
No PostgreSQL, tanto usuários quanto grupos são tratados como **roles**. Uma role pode:
- Fazer login no banco de dados (role de login)
- Ser proprietária de objetos do banco
- Ser membro de outras roles
- Ter privilégios específicos concedidos

### Tipos de Roles
- **Role de Login**: Pode conectar-se ao banco de dados
- **Role de Grupo**: Agrupa outras roles para facilitar o gerenciamento de permissões
- **Superuser**: Tem todos os privilégios no sistema

## Gerenciamento de Usuários (Roles)

### Criando Usuários

```sql
-- Criar um usuário básico
CREATE USER nome_usuario WITH PASSWORD 'senha_segura';

-- Criar usuário com opções específicas
CREATE USER desenvolvedor WITH 
    PASSWORD 'dev123'
    LOGIN
    CREATEDB
    VALID UNTIL '2025-12-31';

-- Criar role sem login (para agrupamento)
CREATE ROLE grupo_leitura;
```

### Opções de Criação de Usuários

| Opção | Descrição |
|-------|-----------|
| `LOGIN` | Permite login no banco |
| `NOLOGIN` | Não permite login (padrão para roles) |
| `SUPERUSER` | Concede privilégios de superusuário |
| `CREATEDB` | Permite criar bancos de dados |
| `CREATEROLE` | Permite criar outras roles |
| `REPLICATION` | Permite conexões de replicação |
| `PASSWORD` | Define senha para autenticação |
| `VALID UNTIL` | Define data de expiração |

### Alterando Usuários

```sql
-- Alterar senha
ALTER USER nome_usuario WITH PASSWORD 'nova_senha';

-- Conceder privilégio de criar BD
ALTER USER nome_usuario CREATEDB;

-- Remover privilégio
ALTER USER nome_usuario NOCREATEDB;

-- Definir data de expiração
ALTER USER nome_usuario VALID UNTIL '2025-06-30';
```

### Removendo Usuários

```sql
-- Remover usuário
DROP USER nome_usuario;

-- Remover role (mesmo comando)
DROP ROLE nome_role;
```

## Gerenciamento de Grupos

### Criando Grupos

```sql
-- Criar grupo para desenvolvedores
CREATE ROLE desenvolvedores;

-- Criar grupo para analistas
CREATE ROLE analistas NOLOGIN;
```

### Adicionando Usuários a Grupos

```sql
-- Adicionar usuário ao grupo
GRANT desenvolvedores TO usuario1, usuario2;

-- Adicionar com opção de conceder a outros
GRANT desenvolvedores TO usuario1 WITH ADMIN OPTION;
```

### Removendo Usuários de Grupos

```sql
-- Remover usuário do grupo
REVOKE desenvolvedores FROM usuario1;
```

## Sistema de Permissões

### Tipos de Privilégios

#### Privilégios de Banco de Dados
- `CREATE`: Criar esquemas no banco
- `CONNECT`: Conectar ao banco
- `TEMPORARY`: Criar tabelas temporárias

#### Privilégios de Esquema
- `CREATE`: Criar objetos no esquema
- `USAGE`: Acessar objetos no esquema

#### Privilégios de Tabela
- `SELECT`: Consultar dados
- `INSERT`: Inserir dados
- `UPDATE`: Atualizar dados
- `DELETE`: Excluir dados
- `REFERENCES`: Criar chaves estrangeiras
- `TRIGGER`: Criar triggers

### Concedendo Permissões

```sql
-- Permissões de banco de dados
GRANT CONNECT ON DATABASE empresa TO usuario1;
GRANT CREATE ON DATABASE empresa TO desenvolvedores;

-- Permissões de esquema
GRANT USAGE ON SCHEMA public TO usuario1;
GRANT CREATE ON SCHEMA vendas TO desenvolvedores;

-- Permissões de tabela
GRANT SELECT ON TABLE funcionarios TO analistas;
GRANT SELECT, INSERT, UPDATE ON TABLE produtos TO desenvolvedores;
GRANT ALL PRIVILEGES ON TABLE vendas TO gerente_vendas;

-- Permissões em todas as tabelas de um esquema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO usuario_leitura;

-- Permissões futuras (para tabelas que serão criadas)
ALTER DEFAULT PRIVILEGES IN SCHEMA vendas 
GRANT SELECT ON TABLES TO analistas;
```

### Removendo Permissões

```sql
-- Remover permissão específica
REVOKE INSERT ON TABLE produtos FROM usuario1;

-- Remover todas as permissões
REVOKE ALL PRIVILEGES ON TABLE funcionarios FROM usuario1;

-- Remover permissões em cascata
REVOKE desenvolvedores FROM usuario1 CASCADE;
```

## Consultas Úteis para Monitoramento

### Listar Usuários e Roles

```sql
-- Listar todas as roles
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole 
FROM pg_roles 
ORDER BY rolname;

-- Listar apenas usuários que podem fazer login
SELECT rolname, rolsuper, rolcreatedb 
FROM pg_roles 
WHERE rolcanlogin = true;
```

### Verificar Membros de Grupos

```sql
-- Ver membros de um grupo específico
SELECT 
    r.rolname AS role_name,
    m.rolname AS member_name
FROM pg_roles r
JOIN pg_auth_members am ON r.oid = am.roleid
JOIN pg_roles m ON am.member = m.oid
WHERE r.rolname = 'desenvolvedores';
```

### Verificar Permissões

```sql
-- Permissões de tabela
SELECT 
    schemaname,
    tablename,
    tableowner,
    privileges
FROM pg_tables 
WHERE schemaname = 'public';

-- Permissões detalhadas de uma tabela
SELECT 
    grantee,
    privilege_type,
    is_grantable
FROM information_schema.table_privileges 
WHERE table_name = 'funcionarios';
```

## Boas Práticas

### Segurança
1. **Princípio do Menor Privilégio**: Conceda apenas as permissões mínimas necessárias
2. **Use Grupos**: Organize usuários em grupos para facilitar o gerenciamento
3. **Senhas Fortes**: Implemente políticas de senhas seguras
4. **Auditoria Regular**: Revise periodicamente usuários e permissões

### Organização
1. **Nomenclatura Consistente**: Use padrões para nomes de usuários e grupos
2. **Documentação**: Mantenha registro das permissões concedidas
3. **Separação de Ambientes**: Use usuários diferentes para desenvolvimento, teste e produção

### Exemplo Prático

```sql
-- Cenário: Sistema de vendas

-- 1. Criar grupos
CREATE ROLE vendedores NOLOGIN;
CREATE ROLE gerentes NOLOGIN;
CREATE ROLE analistas NOLOGIN;

-- 2. Criar usuários
CREATE USER vendedor1 WITH PASSWORD 'vend123' LOGIN;
CREATE USER gerente_vendas WITH PASSWORD 'ger123' LOGIN;
CREATE USER analista_bi WITH PASSWORD 'ana123' LOGIN;

-- 3. Adicionar usuários aos grupos
GRANT vendedores TO vendedor1;
GRANT gerentes TO gerente_vendas;
GRANT analistas TO analista_bi;

-- 4. Conceder permissões aos grupos
-- Vendedores: podem consultar produtos e inserir vendas
GRANT SELECT ON produtos TO vendedores;
GRANT SELECT, INSERT ON vendas TO vendedores;

-- Gerentes: têm acesso total às vendas
GRANT ALL PRIVILEGES ON vendas TO gerentes;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO gerentes;

-- Analistas: apenas leitura para relatórios
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analistas;
```

## Comandos de Referência Rápida

```sql
-- Criar usuário
CREATE USER nome WITH PASSWORD 'senha' LOGIN;

-- Criar grupo
CREATE ROLE grupo NOLOGIN;

-- Adicionar ao grupo
GRANT grupo TO usuario;

-- Conceder permissão
GRANT SELECT ON tabela TO usuario;

-- Remover permissão
REVOKE SELECT ON tabela FROM usuario;

-- Listar usuários
\du

-- Ver permissões de tabela
\dp nome_tabela
```

## Conclusão

O sistema de usuários, grupos e permissões do PostgreSQL oferece flexibilidade e segurança para controlar o acesso aos dados. O uso adequado de roles e a aplicação do princípio do menor privilégio são fundamentais para manter a segurança do banco de dados.