object intensidadGlobal{
    var property valorIntensidadElevada = 80

    method modificarIntensidadElevada(nuevoValor) {
      valorIntensidadElevada = nuevoValor
    }
}

class GrupoPersonas{
    const personas = []

    method agregarPersona(nuevaPersona){
        personas.add(nuevaPersona)
    }

    method vivirEventoEnConjunto(evento) {
      personas.forEach({persona => persona.vivirEvento(evento)})
    }

    //Los proximos metodos son creados para los test:
    method estanPorExplotar() = personas.all({persona => persona.estaPorExplotar()})

    method algunoEstaPorExplotar() = personas.any({persona => persona.estaPorExplotar()})
}

class Persona{
    const edad
    const property emociones = []

    method esAdolescente() = edad.between(12, 19) 

    method agregarEmocion(nuevaEmocion) {
      emociones.add(nuevaEmocion)
    }

    method estaPorExplotar() = emociones.all({emocion => emocion.puedeSerLiberada()})

    method vivirEvento(evento) {
      evento.generarImpacto(self)
    }
}

class Evento{
    const property impacto
    const property descripcion

    method generarImpacto(persona) {
      persona.emociones().forEach({emocion => emocion.intentarLiberar(self)})
    }
}


class Emocion{
    var intensidad
    const eventosVividos = []
    var liberada = false

    method getIntensidad() = intensidad

    method intensidadEsElevada() = self.getIntensidad() >= intensidadGlobal.valorIntensidadElevada()

    method puedeSerLiberada() = self.intensidadEsElevada()

    method liberarse(evento) {
      intensidad -= (evento.impacto().abs())  // le saco el valor absoluto a impacto porque la consigna dice que el impacto de un evento se expresa con un número positivo
      liberada = true
    }

    method intentarLiberar(evento) {
      eventosVividos.add(evento)
      if(self.puedeSerLiberada() && liberada.negate()){  // compruebo si puede liberarse y si ya no fue liberada antes
        self.liberarse(evento)
      }
    }

    method eventosExperimentados() = eventosVividos.size()
}

class Furia inherits Emocion(intensidad = 100){
    const palabrotas = []

    method aprenderPalabrota(nuevaPalabra) {
      palabrotas.add(nuevaPalabra)
    }
    method olvidarPalabrota(palabrota) {
      palabrotas.remove(palabrota)
    }

    override method puedeSerLiberada() = super() && palabrotas.any({palabra => palabra.size() > 7})

    override method liberarse(evento) {
      super(evento)
      palabrotas.remove(palabrotas.first())
    }
}

class Alegria inherits Emocion{

    override method getIntensidad() = intensidad.abs()

    override method puedeSerLiberada() = super() && self.eventosExperimentados().even()
}

class Tristeza inherits Emocion{
    var causa = "Melancolia"

    override method puedeSerLiberada() = super() && causa != "Melancolia"

    override method liberarse(evento) {
      super(evento)
      causa = evento.descripcion()
    }
}

class Desagrado inherits Emocion{
    override method puedeSerLiberada() = super() && self.eventosExperimentados() > self.getIntensidad()
}

class Temor inherits Desagrado{

}

class Ansiedad inherits Emocion{
    var depresion

    override method puedeSerLiberada() = super() && depresion < self.getIntensidad()

    override method liberarse(evento) {
      super(evento)
      depresion = 0
    }
}

/*
EXPLICACION ANSIEDAD:
    - Fue muy util el concepto de polimorfismo porque gracias a este todas las emociones responden a cualquier evento, sin necesidad de modificar nada, ni crear distintas clases de eventos
    - La herencia fue escencial para las emociones y por supuesto, para la Ansiedad, ya que pude evitar el codigo repetido de metodos como el de puedeSerLiberada y liberarse, conteniendo este codigo repetido en la superclase Emocion.
    Tambien la herencia fue muy util para almacenar los atributos compartidos por las emociones, tales como la intensidad, los eventos vividos y el estado liberado
*/