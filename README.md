# 🛡️ SmartHome Guardian - Mobile

 *"Sua casa protege você, mesmo quando você não está nela."*

Aplicativo móvel oficial do sistema SmartHome Guardian, desenvolvido como parte de um Trabalho de Conclusão de Curso (TCC). O foco deste aplicativo é receber notificações em tempo real, exibir o status de segurança da residência e manter o histórico de alertas gerados por sensores IoT (simulados).

---

## Tecnologias Utilizadas

O ecossistema do SmartHome Guardian é composto por três frentes, garantindo comunicação em tempo real entre o hardware simulado e os usuários:

**Aplicativo Mobile (Este repositório)**
* **Framework:** Flutter
* **Linguagem:** Dart
* **Comunicação em Tempo Real:** WebSockets (Socket.io-client)
* **Gerenciamento de Estado:** Provider / Riverpod (A definir)

**Arquitetura Geral do Sistema (Integração)**
* **Backend:** Node.js com Express e Socket.io (API REST e WebSockets)
* **Plataforma Web / Dashboard:** React.js
* **Banco de Dados:** MySQL / PostgreSQL

---

## 📅 Cronograma e Metas de Desenvolvimento

Para garantir a entrega do TCC em 4 meses, o desenvolvimento mobile seguirá as seguintes metas semanais/diárias:

### Fundações e Prototipação (Foco atual)
- [x] Definição de requisitos e funcionalidades.
- [x] Criação da identidade visual (Azul escuro, Verde, Branco e Vermelho).
- [x] Protótipos das telas no Figma.
- [x] Configuração inicial do repositório Flutter.
- [x] **Meta da Semana:** Concluir a UI da Tela de Login.

### Estruturação Visual (Front-end Mobile)
O objetivo deste mês é ter todas as 5 telas prontas, com navegação fluida, operando com dados "mockados" (falsos) para testes de usabilidade.
- [x] **Semana 1:** Construção da tela **Home** (Status da casa, temperatura e último evento).
- [x] **Semana 2:** Construção da tela de **Alertas** (Lista de notificações).
- [x] **Semana 3:** Construção da tela de **Histórico** (Timeline de eventos anteriores).
- [ ] **Semana 4:** Construção da tela de **Perfil** e finalização do roteamento entre telas (Navigation).

### Integração e Tempo Real (O Coração do App)
O mês mais crítico. O aplicativo será conectado ao Backend em Node.js criado pelo Rafael.
- [ ] **Semana 1:** Consumo da API REST (Autenticação/Login e busca de histórico).
- [ ] **Semana 2:** Configuração do Socket.io no Flutter.
- [ ] **Semana 3:** Integração dos gatilhos de IoT simulado (App reage automaticamente quando um evento é disparado na Web).
- [ ] **Semana 4:** Tratamento de erros, loading states e refinamento de conexões perdidas.

### Polimento, Testes e Apresentação
- [ ] **Semana 1:** Testes de usabilidade e caça a bugs (QA).
- [ ] **Semana 2:** Ajustes visuais finos (sombras, animações de transição, ícones).
- [ ] **Semana 3:** Ensaios práticos dos **5 Cenários de Demonstração** da banca.
- [ ] **Semana 4:** Congelamento de código (Code Freeze), geração do APK/IPA e entrega da documentação final.

---

## 🚀 Como executar o projeto localmente

1. Certifique-se de ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
2. Clone este repositório:
   ```bash
   git clone [URL_DO_SEU_REPOSITORIO]