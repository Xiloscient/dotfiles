Even though quantum computers are vastly different from classical computers, they also utilize gates. Below is the representation of a binary half-adder.


```python
from qiskit import *
from qiskit.visualization import plot_histogram, plot_bloch_multivector
from math import sqrt, pi
simulator =Aer.get_backend('qasm_simulator')
```

# The Half adder


```python
qc_ha = QuantumCircuit(4,2)
# encode inputs in qubits 0 and 1
qc_ha.x(0) # For a=0, remove the this line. For a=1, leave it.
qc_ha.x(1) # For b=0, remove the this line. For b=1, leave it.
qc_ha.barrier()
# use cnots to write the XOR of the inputs on qubit 2
qc_ha.cx(0,2)
qc_ha.cx(1,2)
# use ccx to write the AND of the inputs on qubit 3
qc_ha.ccx(0,1,3)
qc_ha.barrier()
# extract outputs
qc_ha.measure(2,0) # extract XOR value
qc_ha.measure(3,1) # extract AND value
qc_ha.draw()
```




​    
![png](output_3_0.png)
​    




​    
![png](output_3_1.png)
​    


The barriers neatly split the circut into the three important parts. 
- The rightmost part with the **Pauli-X** gates encodes two bits into 1.
- Then after the barrier we have the operations on the qubits. Here we have two **CNOT** Gates working together to form a kind of XOR. Then the carry over is performed by the **Toffoli**, kind of an AND gate. 
- After the last barrier the output is extracted by being measureed and encoded onto classical bits. 

Measurement here is trivial since there is no superposition. In examples with such superposition there would be a probability for each result with the actual result only being determined after wave function collapse (measurement).


Here we expect to measure $10$ since $1+1=10_b$.


```python
counts = execute(qc_ha,simulator ).result().get_counts()
plot_histogram(counts)
```




​    
![png](output_5_0.png)
​    




​    
![png](output_5_1.png)
​    


# Representing Qubits
Classical bits are represented by a boolean value. They can be either 0 or 1, nothing else. Qubits take far more complex representations during calculation and only at measurement colapse to these boolean values. The basic cases of 0 and 1 still exist here and are represented as follows:
$$ |0\rangle = \begin{bmatrix} 1 \\ 0 \end{bmatrix} \, \, \, \, |1\rangle =\begin{bmatrix} 0 \\ 1 \end{bmatrix}$$
These are also the basis vectors of the hilbert space. This also means that all other vectors can be expressed as a combination of these two. If a vector is formed out of the linear combination of these two it is in superposition since it is "neither here nor there".
$$ |q_0\rangle = \begin{bmatrix} \tfrac{1}{\sqrt{2}} \\ \tfrac{i}{\sqrt{2}} \end{bmatrix}= \tfrac{1}{\sqrt{2}}\begin{bmatrix} 1 \\ 0 \end{bmatrix} + \tfrac{i}{\sqrt{2}}\begin{bmatrix} 0 \\ 1 \end{bmatrix} = \tfrac{1}{\sqrt{2}}|0\rangle + \tfrac{i}{\sqrt{2}}|1\rangle$$
This vector $|q_0\rangle$ is the statevector of the qubit which shows the state of the current qubit. It holds all possible information about this particular qubit. 


```python
qc = QuantumCircuit(1)
qc.initialize([0,1], 0)
qc.draw()
qc.save_statevector()
out_state = execute(qc, simulator).result().get_statevector()
print(out_state)
```

    [0.+0.j 1.+0.j]




![png](output_7_1.png)
    


This code creates a circuit with one qubit and then initializes that qubit $q_0$ to the state $|1\rangle$. It then prints the statevector which shows the expected result. Most notably, it is shown as a complex number.


```python
qc.measure_all()
qc.draw()
counts = execute(qc,simulator ).result().get_counts()
plot_histogram(counts)
```

​    




![png](output_9_1.png)
    




![png](output_9_2.png)
    


All behaves as we expect it to.

Let us now use the more complex qubit from the previous example.


```python
qc = QuantumCircuit(1)
qc.initialize([1/sqrt(2), 1j/sqrt(2)], 0)
qc.save_statevector()
result = execute(qc, simulator).result()
plot_histogram(result.get_counts())
print(result.get_statevector())
```

    [0.70710678+0.j         0.        +0.70710678j]




![png](output_11_1.png)
    


We now see that we have an equal possibility of measuring $|0\rangle$ and $|1\rangle$. To understand this we will go more in-depth on the measurement process

## Measurement: 
In order to find the probability of measuring a state $|\psi\rangle$ in the state $|x\rangle$ we do:
$$ p(|x\rangle) = | \langle x| \psi \rangle|^2$$
The braket here present is nothing but the inner product of the row vector $\langle x|$ and the column vector $|\psi\rangle$. In order to convert from a column vector to a row vector, simply take the conjugate transpose of that vector.

Now let us look at the original qubit and its probability to be measured in $|0\rangle$:
$$\begin{aligned}
p(|0\rangle) & = | \langle 0| q_0 \rangle|^2 \\
|q_0\rangle & = \tfrac{1}{\sqrt{2}}|0\rangle + \tfrac{i}{\sqrt{2}}|1\rangle \\
\langle 0|& = |0\rangle^\dagger = \begin{bmatrix}1 \\ 0 \end{bmatrix}^\dagger = \begin{bmatrix}1 & 0 \end{bmatrix} \\
\langle 0| q_0 \rangle  & = \tfrac{1}{\sqrt{2}}\langle 0|0\rangle + \tfrac{i}{\sqrt{2}}\langle 0|1\rangle \\
& = \tfrac{1}{\sqrt{2}}\begin{bmatrix}1 & 0 \end{bmatrix}\begin{bmatrix}1 \\ 0 \end{bmatrix} + \tfrac{i}{\sqrt{2}}\begin{bmatrix}1 & 0 \end{bmatrix}\begin{bmatrix}0 \\ 1 \end{bmatrix} \\
& = \tfrac{1}{\sqrt{2}} (1 \cdot 1 + 0 \cdot 0) + \tfrac{i}{\sqrt{2}} (1 \cdot 0 + 0 \cdot 1) \\
& = \tfrac{1}{\sqrt{2}}\cdot 1 +  \tfrac{i}{\sqrt{2}} \cdot 0\\
& = \tfrac{1}{\sqrt{2}}\\
|\langle 0| q_0 \rangle|^2 & = \left(\tfrac{1}{\sqrt{2}}\right)^2= \tfrac{1}{2}
\end{aligned}$$
This means that the statevector always has to be propperly normalized, meaning its magnitude must be 1.
$$\langle \psi | \psi \rangle = 1$$
We now break $|\psi\rangle$ apart into the basis vectors: 
$$|\alpha|^2 +  |\beta|^2 = 1$$
This explains the many $\sqrt{2}$ that have been appearing in amplitudes. It is actually impossible to have a vector that is not normalized since this would mean that its probability to give a measurement is not 1. This would in turn break quantum mechanics since it would mean that the qubit is not measurable.

### Global Phase
Let us attempt to apply the measurement for an amplitude of $i$ and the likelihood of measuring $|1\rangle$.
$$|\langle x| (i|1\rangle) |^2 = | i \langle x|1\rangle|^2 = |\langle x|1\rangle|^2$$
We notice that the factor $i$ completely vanishes. Regardless of the state $|x\rangle$ of the qubit. Since the only way for us to get information is to measure and here we would measure the same thing, it follows that the probabilities of $i|1\rangle$ and $|1\rangle$ are identical. This is valid for any factor $\gamma$ where $|\gamma|=1$. 
$$|\langle x| ( \gamma |a\rangle) |^2 = | \gamma \langle x|a\rangle|^2 = |\langle x|a\rangle|^2$$ These factors are called global phases. States that differ only by this factor are indistinguishable. This is distinct from relative phase which is the phase difference between terms in superposition.
### Observer Effect
The observer effect is the rather simple quantum mechanical effect that states that once measured a qubit remains in its state. It is impossible to revert the collapse of the wave function so once the qubit has been measured as $|0\rangle$ it will remain such. The result is that we can only measure at the end of our operation which makes debuggin especially difficult. An Example with the following qubit:
$$|q\rangle = \tfrac{i}{\sqrt{2}}|0\rangle + \tfrac{1}{\sqrt{2}}|1\rangle$$


```python
qc = QuantumCircuit(1)
initial_state = [0.+1.j/sqrt(2),1/sqrt(2)+0.j]
qc.initialize(initial_state, 0)
qc.measure_all() #Comment out this line to see
qc.save_statevector()
qc.draw()
state = execute(qc, simulator).result().get_statevector()
print("State of Measured Qubit = " + str(state))
```

    State of Measured Qubit = [0.+0.j 1.+0.j]




![png](output_14_1.png)
    


Here we can cleary see that even though the qubit is a superposition the result is always either $|0\rangle$ or $|1\rangle$. Uncomment line 4 to see.
## The Bloch Sphere
Our current perception of a qubit is as follows:
$$|\psi\rangle = \alpha|0\rangle + \beta|1\rangle$$
$$\alpha,\beta \in \mathbb{C}$$
Global phase is not measurable. This means that we can only measure the difference in phase between states. We can then use Euler's identity to confine $\alpha$ and $\beta$ to be real numbers, with the addition of a term.
$$|\psi\rangle = \alpha|0\rangle + e^{i\phi}\beta|1\rangle$$
$$\alpha, \beta, \phi \in \mathbb{R}$$
The qubit must be normalized therefore we gather:
$$\sqrt{\alpha^2+\beta^2}=1$$
With the Trigonometric identity:
$$\sqrt{\sin^2x+\cos^2x}=1$$
We can now express them both in terms of $\theta$
$$ \alpha = \cos{\tfrac{\theta}{2}}, \quad \beta=\sin{\tfrac{\theta}{2}}$$
The Qubit now looks as follows:
$$|q\rangle = \cos{\tfrac{\theta}{2}}|0\rangle + e^{i\phi}\sin{\tfrac{\theta}{2}}|1\rangle$$
$$\theta,\phi \in \mathbb{R}$$
We can now interpret $\theta$ and $\phi$ as sperical co-ordinates of Radius 1.

# Single Qubit Gates
In order to see the effect a certain gate has on a qubit, simply mupltiply the statevector by the Gate.
## Pauli Gates
### Pauli-X Gate
$$ X = \begin{bmatrix} 0 & 1 \\ 1 & 0 \end{bmatrix} = |0\rangle\langle1| + |1\rangle\langle0|$$
We can quickly see that the X-Gate switches a $|0\rangle$ into a $|1\rangle$.
$$ X|0\rangle = \begin{bmatrix} 0 & 1 \\ 1 & 0 \end{bmatrix}\begin{bmatrix} 1 \\ 0 \end{bmatrix} = \begin{bmatrix}0\cdot1+1\cdot 0 \\ 1 \cdot 1 + 0 \cdot 0 \end{bmatrix} = \begin{bmatrix} 0 \\ 1 \end{bmatrix} = |1\rangle$$


```python
qc_x = QuantumCircuit(1)
qc_x.x(0)
qc_x.draw()
qc_x.save_statevector()
state_x = execute(qc_x, simulator).result().get_statevector()
plot_bloch_multivector(state_x)
print(state_x)
```

    [0.+0.j 1.+0.j]




![png](output_16_1.png)
    


    /home/xilo/.local/lib/python3.9/site-packages/qiskit/visualization/bloch.py:68: MatplotlibDeprecationWarning: 
    The M attribute was deprecated in Matplotlib 3.4 and will be removed two minor releases later. Use self.axes.M instead.
      x_s, y_s, _ = proj3d.proj_transform(xs3d, ys3d, zs3d, renderer.M)




![png](output_16_3.png)
    


On the Bloch sphere we can therefore think of the X-Gate as a rotation by $\pi$ radians on the x-axis.
### Pauli-Y and Pauli-Z
$$Y = \begin{bmatrix} 0 & -i \\ i & 0 \end{bmatrix} \quad\quad\quad\quad Z = \begin{bmatrix} 1 & 0 \\ 0 & -1 \end{bmatrix}$$
$$ Y = -i|0\rangle\langle1| + i|1\rangle\langle0| \quad\quad Z = |0\rangle\langle0| - |1\rangle\langle1|$$
Similarly to how the X Gate performed a rotation on the x-axis, the Y and Z Gates will perform a rotation of $\pi$ around their respective axis. Let's look at the Y-Gate
$$ Y|0\rangle = \begin{bmatrix} 0 & -i \\ i & 0 \end{bmatrix}\begin{bmatrix}1 \\ 0 \end{bmatrix} =\begin{bmatrix} 0 \\ i \end{bmatrix}$$


```python
qc = QuantumCircuit(1)
qc.y(0)
qc.save_statevector()
state = execute(qc, simulator).result().get_statevector()
plot_bloch_multivector(state)
print("State after Y: " + str(state))
print("State after X: " + str(state_x))
```

    State after Y: [0.-0.j 0.+1.j]
    State after X: [0.+0.j 1.+0.j]


    /home/xilo/.local/lib/python3.9/site-packages/qiskit/visualization/bloch.py:68: MatplotlibDeprecationWarning: 
    The M attribute was deprecated in Matplotlib 3.4 and will be removed two minor releases later. Use self.axes.M instead.
      x_s, y_s, _ = proj3d.proj_transform(xs3d, ys3d, zs3d, renderer.M)




![png](output_18_2.png)
    


This is also a lovely example of Global phase. In the output we have the Statevector of the previous simulation with the X-Gate, as well as the new one with the Y-Gate. The bloch sphere shows the qubit after Y. We can clearly see that there is a difference in the statevectors mathematically, that difference however does not represent itself in physical reality, therefore the bloch sphere shows the result.

If we apply the Z gate to our qubit we notice that nothing happens. This is the case since $|0\rangle$ and $|1\rangle$ are the two eigenstates of the Z-Matrix. This is why using $|0\rangle$ and $|1\rangle$ as the basis vectors is called the Z-Basis. Similarly the X-Basis is gained by its two Orthogonal Eigenvectors:
$$ |+\rangle = \tfrac{1}{\sqrt{2}}(|0\rangle + |1\rangle) = \tfrac{1}{\sqrt{2}}\begin{bmatrix} 1 \\ 1 \end{bmatrix}$$
$$ |-\rangle = \tfrac{1}{\sqrt{2}}(|0\rangle - |1\rangle) = \tfrac{1}{\sqrt{2}}\begin{bmatrix} 1 \\ -1 \end{bmatrix}$$
Again the $\tfrac{1}{\sqrt{2}}$ comes from normalizing the vectors.

## Hadamard Gate
This Gate allows us to move away from the fixed $|0\rangle$ and $|1\rangle$ values we had before. It thereby puts the qubit into superposition. It has the Matrix: 
$$ H = \tfrac{1}{\sqrt{2}}\begin{bmatrix} 1 & 1 \\ 1 & -1\end{bmatrix}$$
The transformations it  applies rotate us by $\tfrac{\pi}{2}$, therfore transforming the state of the qubit from the Z basis into the X basis.
$$H|0\rangle = |+\rangle \hspace{30pt} H|1\rangle = |-\rangle $$ 
## Phase Gate
The P-Gate needs a parameter $\phi \in \mathbb{R}$ (in radians) to tell it what to do. It is going to then rotate the qubit by $\phi$ along the Z-Axis. Write it as follows: `qc.p(angle,qubitIndex)`
$$ P(\phi) = \begin{bmatrix} 1 & 0 \\ 0 & e^{i\phi} \end{bmatrix}$$
If $\phi=\pi$ then the P-Gate is the same thing as the Z-Gate.
## I, S, T-Gate
### I-Gate
The I-Gate is simply the Identity matrix which does nothing. It has no effect but can be used for testing purposes. 
### S-Gate
The S-Gate is a a P-Gate with $\phi = \tfrac{\pi}{2}$ As obvious by the angle it does a quarter of a turn on the Z-axis. It is sometimes called $\sqrt{Z}$-Gate since applying it twice is the same as applying a Z-Gate. It is therefore also  one of a few gates that are not their own inverses. Therefore there is an associated gate S$^\dagger$ that is the conjugate transpose of S.
$$ S = \begin{bmatrix} 1 & 0 \\ 0 & e^{\frac{i\pi}{2}} \end{bmatrix}, \quad  S^\dagger = \begin{bmatrix} 1 & 0 \\ 0 & e^{-\frac{i\pi}{2}} \end{bmatrix}$$
### T-Gate:
The T-Gate is a P-Gate with $\phi=\tfrac{\pi}{4}$. Therefore it is also sometimes reffered to as the $\sqrt[4]{Z}$-Gate.
$$ T = \begin{bmatrix} 1 & 0 \\ 0 & e^{\frac{i\pi}{4}} \end{bmatrix}, \quad  T^\dagger = \begin{bmatrix} 1 & 0 \\ 0 & e^{-\frac{i\pi}{4}} \end{bmatrix}$$
## The U-Gate
The U-Gate is the   generalized version of all possible Gates. It takes three parameters and spits out a Gate. Any single qubit gate can be constructed from it.
$$ U(\theta, \phi, \lambda) = \begin{bmatrix} \cos(\frac{\theta}{2}) & -e^{i\lambda}\sin(\frac{\theta}{2}) \\
            e^{i\phi}\sin(\frac{\theta}{2}) & e^{i(\phi+\lambda)}\cos(\frac{\theta}{2})
     \end{bmatrix}$$ 
Fortunately for me, this is rarely used since its unreadable. Here are two of the Previous Gates expressed in terms of the U-Gate
$$\begin{aligned}
U(\tfrac{\pi}{2}, 0, \pi) = \tfrac{1}{\sqrt{2}}\begin{bmatrix} 1 & 1 \\
            1 & -1
     \end{bmatrix} = H
& \quad &
U(0, 0, \lambda) = \begin{bmatrix} 1 & 0 \\
            0 & e^{i\lambda}\\
     \end{bmatrix} = P
\end{aligned}$$


```python

```
