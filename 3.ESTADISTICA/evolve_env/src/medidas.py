import numpy as np
import pandas as pd


# Crear la media sin la funcion mean de numpy
# Explicacion: 
#           La media se calcula sumando todos los valores de la lista y dividiendo por el número total de elementos. 
#           Esto se puede hacer utilizando la función sum() para obtener la suma de los elementos y la función len() para obtener el número de elementos en la lista.
# Su uso es para:
#           La media es una medida de tendencia central que se utiliza para representar el valor promedio de un conjunto de datos.  
def media_evolve(lista_datos: list):
    return sum(lista_datos) / len(lista_datos)

# Crear la mediana sin la funcion median de numpy
# Explicacion: 
#           La mediana se calcula ordenando los datos y luego encontrando el valor central. Si el número de elementos es impar, 
#           la mediana es el valor en la posición central. Si el número de elementos es par, la mediana es el promedio de los dos valores centrales.
# Su uso es para:
#           La mediana es una medida de tendencia central que se utiliza para representar el valor que divide un conjunto de datos en dos partes iguales.
def mediana_evolve(lista_datos: list):
    sorted_datos = sorted(lista_datos)
    n = len(sorted_datos)
    if n % 2 == 0:
        # // me deja una division entera, es decir, no es float
        return (sorted_datos[n//2 - 1] + sorted_datos[n//2]) / 2
    else:
        return sorted_datos[n//2]

# Crear el percentil sin la funcion percentile de numpy
# Explicacion: 
#           El percentil se calcula ordenando los datos y luego encontrando el valor en la posición correspondiente al percentil deseado.
# Su uso es para:
#           El percentil es una medida de posición que se utiliza para indicar el valor por debajo del cual se encuentra un cierto porcentaje de los datos.
def percentil_evolve(lista_datos: list, percentil: int):
    sorted_datos = sorted(lista_datos)
    n = len(sorted_datos)
    posicion = int(n * percentil / 100)
    return sorted_datos[posicion]

# Crear la varianza sin la funcion var de numpy
# Explicacion:
#           La varianza se calcula sumando los cuadrados de las diferencias entre cada valor y la media, 
#           y luego dividiendo por el número total de elementos.
# Su uso es para:
#           La varianza es una medida de dispersión que se utiliza para representar la variabilidad de un conjunto de datos. 
#            Una varianza alta indica que los datos están más dispersos, mientras que una varianza baja indica que los datos están más agrupados alrededor de la media.
def varianza_evolve(lista_datos: list):
    media = media_evolve(lista_datos)
    n = len(lista_datos)
    return sum((x - media) ** 2 for x in lista_datos) / n

# Crear la desviación estándar sin la funcion std de numpy
# Explicacion:
#           La desviación estándar se calcula tomando la raíz cuadrada de la varianza.
# Su uso es para:
#           La desviación estándar es una medida de dispersión que se utiliza para representar la variabilidad de un conjunto de datos en las mismas unidades que los datos originales.
def desviacion_evolve(lista_datos: list):
    return varianza_evolve(lista_datos) ** 0.5

# Crear el IQR (CUARTIL) sin la funcion IQR de numpy
# Explicacion:
#           El IQR se calcula restando el primer cuartil (Q1) dato en el 25% del tercer cuartil (Q3) dato en el 75%.
# Su uso es para:
#           El IQR es una medida de dispersión que se utiliza para representar el rango intercuartílico de un conjunto de datos.
# Un rango intercuartílico es un rango que abarca el 50% central de los datos.
# Un rango intercuartílico alto indica que los datos están más dispersos, mientras que un rango intercuartílico bajo indica que los datos están más agrupados alrededor de la mediana.
def IQR_evolve(lista_datos: list):
    q1 = percentil_evolve(lista_datos, 25)
    q3 = percentil_evolve(lista_datos, 75)
    return q3 - q1



if __name__ == "__main__":

    np.random.seed(42)
    edad = list(np.random.randint(20, 60, 100))
    salario =  list(np.random.normal(45000, 15000, 100))
    experiencia = list(np.random.randint(0, 30, 100))

    np.random.seed(42)

    df = pd.DataFrame({
        'edad': np.random.randint(20, 60, 100),
        'salario': np.random.normal(45000, 15000, 100),
        'experiencia': np.random.randint(0, 30, 100)
    })
    
    print("Resultado pandas:")
    print("-----------------------------")
    print(df.describe())

    print("Resultado edad:")
    print("-----------------------------")
    print(media_evolve(edad))
    print(mediana_evolve(edad)) 
    print(percentil_evolve(edad, 50))
    print(varianza_evolve(edad))
    print(desviacion_evolve(edad))
    print(IQR_evolve(edad))

    print(media_evolve(salario))
    print(mediana_evolve(salario))
    print(percentil_evolve(salario, 50))
    print(varianza_evolve(salario))
    print(desviacion_evolve(salario))
    print(IQR_evolve(salario))

    print(media_evolve(experiencia))
    print(mediana_evolve(experiencia))
    print(percentil_evolve(experiencia, 50))
    print(varianza_evolve(experiencia))
    print(desviacion_evolve(experiencia))
    print(IQR_evolve(experiencia))