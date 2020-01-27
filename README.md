# Score Fusion in Multimodal Automated Border Controls

Matlab source code for the paper:

	A. Anand, R. Donida Labati, A. Genovese, E. Muñoz, V. Piuri, F. Scotti, G. Sforza, 
    "Enhancing the performance of multimodal Automated Border Control systems", 
    in Proc. of the 15th Int. Conf. of the Biometrics Special Interest Group (BIOSIG 2016), 
    Darmstadt, Germany, pp. 1-5, September 21-23, 2016. ISBN: 978-3-8857-9654-1. 
    DOI: 10.1109/BIOSIG.2016.7736922
    https://ieeexplore.ieee.org/document/7736922

Project page:

http://iebil.di.unimi.it/projects/abc4eu

Citation:

    @InProceedings {biosig16,
        author = {A. Anand and R. {{Donida Labati}} and A. Genovese and E. Muñoz and V. Piuri and F. Scotti and G. Sforza},
        booktitle = {Proc. of the 15th Int. Conf. of the Biometrics Special Interest Group (BIOSIG 2016)},
        title = {Enhancing the performance of multimodal Automated Border Control systems},
        address = {Darmstadt, Germany},
        pages = {1 - 5},
        month = {9},
        day = {21-23},
        year = {2016}
    }

Main files:

    - launch_scoreFusionABC.m: main file

Required files:

    - ./DATA_scores: Biometric scores
    - ./DATA_qualities: Biometric qualities
    (Biometric scores and qualities must be computed using external softwares)
    (see '.dat' files for details)

Part of the code uses the mixture fitting algorithm described in the paper:

    M. Figueiredo and A. K. Jain, "Unsupervised learning of
    finite mixture models",  IEEE Transaction on Pattern Analysis
    and Machine Intelligence, vol. 24, no. 3, pp. 381-396, March 2002.
    http://www.lx.it.pt/~mtf/
    http://www.lx.it.pt/~mtf/mixturecode2.zip
    
The VLFeat library:

    A. Vedaldi and B. Fulkerson, 
    "VLFeat: An Open and Portable Library of Computer Vision Algorithms", 2008, 
    http://www.vlfeat.org/
    
The code implements some of the algorithms described in:

    K. Nandakumar, Yi Chen, S. Dass, and A. Jain, “Likelihood ratio-based
    biometric score fusion,” IEEE Trans. Pattern Anal. Mach. Intell., vol. 30,
    no. 2, pp. 342–347, 2008.
    
    S. Mika, G. Ratsch, J. Weston, B. Scholkopf and K. R. Mullers, 
    "Fisher discriminant analysis with kernels," Neural Networks for Signal 
    Processing IX: Proceedings of the 1999 IEEE Signal Processing Society Workshop 
    (Cat. No.98TH8468), Madison, WI, USA, 1999, pp. 41-48.

    C. Chia, N. Sherkat, and L. Nolle, “Towards a best linear combination
    for multimodal biometric fusion,” in Proc. of ICPR, 2010, pp. 1176–
    1179.
    
    N. Damer, A. Opel, and A. Nouak, “Biometric source weighting in
    multi-biometric fusion: towards a generalized and robust solution,” in
    Proc. of EUSIPCO, 2014, pp. 1382–1386.

	
