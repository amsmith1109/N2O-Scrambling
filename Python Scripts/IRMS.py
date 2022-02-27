# import importlib
# importlib.reload(IRMS)

class MSMeas():
    sample = None
    reference = None
    molecule = None
    refID = None
    refR = None
    AMU = None

    def __init__(self, sample=None, reference=None, molecule=None, refID=None, AMU=None, refR=None):
        self.sample = sample
        self.reference = reference
        self.molecule = molecule
        self.refID = refID
        self.AMU = AMU
        self.refR = refR

    def R(self, idx):
        import numpy as np
        v = [.5, .5]
        avg_base = np.convolve(self.reference[:, 0], v, 'valid')
        return np.average(self.sample[:,idx]/avg_base)*self.refR[idx]

    def r(self,idx):
        return self.sample[0]

    # def delta(self,idx):
    #     R = self.r(idx)
    #     ref = self.refR(idx)
    #     return (R/ref-1)*1000

    # def diff(array):
    #     return array[0:-1]-array[1:]