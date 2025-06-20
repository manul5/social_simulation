# Social Simulation

Este proyecto es una simulación social desarrollada en Ruby on Rails.

---

## Requisitos previos

- Ruby (recomendado 3.2 o superior)
- Bundler (gestor de gems de Ruby)
- Git

---

## Instalación en **Linux**

### 1. Instalar Ruby y Bundler

**Ubuntu/Debian:**
```sh
sudo apt update
sudo apt install ruby-full build-essential git
gem install bundler
```

**Fedora:**
```sh
sudo dnf install ruby ruby-devel @development-tools git
gem install bundler
```

### 2. Clonar el repositorio

```sh
git clone https://github.com/tu_usuario/social_simulation.git
cd social_simulation
```

### 3. Instalar dependencias

```sh
bundle install
```

### 4. Configurar la base de datos (SQLite)

```sh
rails db:setup
```
Esto crea y migra la base de datos y carga los datos iniciales.

### 5. Ejecutar el servidor

```sh
rails server
```
Abre tu navegador en [http://localhost:3000](http://localhost:3000)

---

## Instalación en **Windows**

### 1. Instalar Ruby y Bundler

- Descarga e instala [Ruby+Devkit para Windows](https://rubyinstaller.org/downloads/).
- Durante la instalación, selecciona la opción para agregar Ruby al PATH.
- Abre una terminal (cmd o PowerShell) y ejecuta:
  ```sh
  gem install bundler
  ```

### 2. Instalar Git

- Descarga e instala [Git para Windows](https://git-scm.com/download/win).

### 3. Clonar el repositorio

```sh
git clone https://github.com/tu_usuario/social_simulation.git
cd social_simulation
```

### 4. Instalar dependencias

```sh
bundle install
```

### 5. Configurar la base de datos (SQLite)

```sh
rails db:setup
```

### 6. Ejecutar el servidor

```sh
rails server
```
Abre tu navegador en [http://localhost:3000](http://localhost:3000)

---

## Notas

- Si recibes errores relacionados con gems nativas, asegúrate de tener instalado el Devkit (en Windows) o los paquetes de desarrollo (en Linux).
- El proyecto usa SQLite, por lo que no necesitas instalar ni configurar un servidor de base de datos externo.
- Si tienes problemas con permisos, ejecuta los comandos con permisos de administrador o usando `sudo` en Linux.

---

¡Listo! Ahora puedes usar y desarrollar el proyecto Social Simulation localmente.