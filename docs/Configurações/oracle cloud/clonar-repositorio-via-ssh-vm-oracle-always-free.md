# Documentação: Configuração de SSH para GitHub em VMs Linux

Este guia descreve como configurar autenticação via **SSH** para acessar repositórios no GitHub a partir de uma VM Linux.  
O objetivo é evitar o uso de senha em cada operação e garantir maior segurança.

---

## 🔑 1. Gerar a chave SSH

```bash
ssh-keygen -t rsa -b 4096 -C "jlfagundes@gmail.com"
```

- `-t rsa -b 4096`: cria uma chave RSA de 4096 bits (segura e compatível).
- `-C`: adiciona um comentário (normalmente seu email).
- Pressione **Enter** para salvar no caminho padrão (`/home/ubuntu/.ssh/id_rsa`).
- Opcional: defina uma **passphrase** para proteger a chave privada.

**Por quê?**  
A chave privada fica na VM e a chave pública será registrada no GitHub. Isso substitui a senha e garante autenticação segura.

**Exemplo real:**
```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ubuntu/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/ubuntu/.ssh/id_rsa
Your public key has been saved in /home/ubuntu/.ssh/id_rsa.pub
```

---

## 📂 2. Adicionar a chave ao agente SSH

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

- O `ssh-agent` mantém a chave carregada em memória.
- `ssh-add` adiciona sua chave privada ao agente.

**Por quê?**  
Assim você não precisa digitar a passphrase toda vez que usar `git`.

---

## 📋 3. Copiar a chave pública

```bash
cat ~/.ssh/id_rsa.pub
```

- Copie todo o conteúdo exibido (começa com `ssh-rsa`).

**Por quê?**  
Essa é a chave que você deve registrar no GitHub. Nunca compartilhe a chave privada (`id_rsa`).

---

## 🌐 4. Registrar a chave no GitHub

1. Vá em **Settings → SSH and GPG keys**.
2. Clique em **New SSH key**.
3. Cole a chave pública.
4. Salve.

**Por quê?**  
O GitHub precisa conhecer sua chave pública para confiar na sua VM.

---

## 🖥️ 5. Testar a conexão

```bash
ssh -T git@github.com
```

- Na primeira vez, confirme com `yes` para adicionar o GitHub ao arquivo `known_hosts`.
- Se aparecer:
  ```
  Hi jlfagundes-dev! You've successfully authenticated...
  ```
  está funcionando.

**Por quê?**  
Esse teste garante que a comunicação SSH está estabelecida corretamente.

---

## 📥 6. Clonar o repositório

```bash
git clone git@github.com:jlfagundes-dev/cetti-saas.git
```

- Use sempre o link **SSH**, não o HTTPS.

**Por quê?**  
Com SSH, você não precisa digitar senha a cada `git push` ou `git pull`.

---

## ✅ Resultados reais do terminal

```
ubuntu@cetti-server:~$ ssh-keygen -t rsa -b 4096 -C "jlfagundes@gmail.com"
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ubuntu/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/ubuntu/.ssh/id_rsa
Your public key has been saved in /home/ubuntu/.ssh/id_rsa.pub
...
ubuntu@cetti-server:~$ ssh -T git@github.com
The authenticity of host 'github.com (140.82.113.3)' can't be established.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'github.com' (ED25519) to the list of known hosts.
Hi jlfagundes-dev! You've successfully authenticated, but GitHub does not provide shell access.
ubuntu@cetti-server:~$ git clone git@github.com:jlfagundes-dev/cetti-saas.git
```

---

## 📌 Conclusão

Seguindo este passo a passo, você configura autenticação SSH em qualquer VM Linux para acessar o GitHub sem precisar de senha.  
Esse processo é reutilizável em qualquer servidor futuro: basta gerar uma nova chave, registrar no GitHub e clonar via SSH.
```