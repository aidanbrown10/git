PROGRAM MAIN
  ! test various subroutines
  USE KEYS
  USE NETWORKUTIL
  USE GENUTIL
  USE TESTMOD
  USE DIFFUTIL
  USE NETWORKPROPAGATE
  
  IMPLICIT NONE
  TYPE(NETWORK), TARGET :: NET
  TYPE(NETWORK), POINTER :: NETP

  NETP=>NET

  CALL READKEY
  
  
  CALL TESTPROPAGATE
  !CALL TESTFZERO
  !CALL TESTSTEPFROMNODE
  !CALL TESTNETWORKFROMFILE
  !CALL TESTSAMPLEFPT
  !CALL TESTBROWNDYN

  CALL CLEANUPNETWORK(NETP)
CONTAINS
  SUBROUTINE TESTPROPAGATE
    ! test propagation along network
    IMPLICIT NONE
    INTEGER :: STARTNODE, PC
    DOUBLE PRECISION, ALLOCATABLE :: NODEFPT(:,:)
    DOUBLE PRECISION :: TESTARR(2,3)
    
    STARTNODE = 1    

    ! TESTARR(1,:) = (/1D0,2D0,3D0/)
    ! TESTARR(2,:) = (/-1D0,2D0,3D0/)
    ! PRINT*, 'TESTX1', ALL(TESTARR.GT.0,2)
    
    CALL NETWORKFROMFILE(NETP,NETFILE)
    ALLOCATE(NODEFPT(NPART,NETP%NNODE))
    
    CALL RUNPROPAGATE(NETP,NPART,STARTNODE,NSTEP,1d0,NODEFPT)

    ! for each particle output FPTs
    OPEN(UNIT=99,FILE=OUTFILE)
    DO PC = 1,NPART
       WRITE(99,*) PC, NODEFPT(PC,:)
    ENDDO
    CLOSE(99)
    
    DEALLOCATE(NODEFPT)
    CALL CLEANUPNETWORK(NETP)
  END SUBROUTINE TESTPROPAGATE
  
  SUBROUTINE TESTSAMPLEFPT
    ! test routine for sampling first passage time from a 2-abs domain
    IMPLICIT NONE
    DOUBLE PRECISION :: FPT(NPART)
    INTEGER :: WHICHLEAVE(NPART)   
    INTEGER :: T, PC
    DOUBLE PRECISION :: X0

    X0 = 0.5D0

    
    ! DO T = 0,100
    !    PRINT*, 1.1**T, EXP(-1.1D0**T)
    ! ENDDO

    ! Original testing run to plot analytical function
    !CALL SAMPLEFPT2ABS(0.1D0,1D0,1D0,FPT(1),WHICHLEAVE(1))
    !RETURN
    
    ! Run sampler
    OPEN(UNIT=99,FILE='test.out')
    DO PC = 1,NPART
       CALL SAMPLEFPT2ABS(2D0,10D0,1D0,FPT(PC),WHICHLEAVE(PC))
       write(99,*) PC, WHICHLEAVE(PC), FPT(PC)
    ENDDO
    CLOSE(99)
  END SUBROUTINE TESTSAMPLEFPT

  SUBROUTINE TESTBROWNDYN
    ! test brownian dynamics sims in 1D with 2 absorbing boundaries    
    IMPLICIT NONE
    INTEGER :: WHICHLEAVE(NPART)
    DOUBLE PRECISION :: LEAVETIME(NPART)
    INTEGER :: PC
    DOUBLE PRECISION :: X0
    
    ! run BD sims
    X0 = 0.5 
    CALL BROWNDYNFPT2ABS(X0,NPART,NSTEP,DELT,WHICHLEAVE,LEAVETIME)

    ! output results
    OPEN(UNIT=99,FILE='test.bd.out')
    DO PC = 1,NPART
       WRITE(99,*) PC, WHICHLEAVE(PC), LEAVETIME(PC)
    ENDDO
    CLOSE(99)
  END SUBROUTINE TESTBROWNDYN
  
  SUBROUTINE TESTNETWORKFROMFILE
    ! test ability to read in network from file
    IMPLICIT NONE
    INTEGER :: EI, NI
    
    CALL NETWORKFROMFILE(NETP,NETFILE)

    PRINT*, 'Edge connectivities and lengths:'
    DO EI = 1,NETP%NEDGE      
       PRINT*, EI, NETP%EDGENODE(EI,:), NETP%EDGELEN(EI)
    END DO

    PRINT*, 'Edges connected to each node:'
    DO NI = 1,NETP%NNODE
       PRINT*, NI, NETP%NODEEDGE(NI,1:NETP%NODEDEG(NI)), NETP%NODELEN(NI,1:NETP%nODEDEG(NI))
    ENDDO
    
    PRINT*, 'Nodes connected to each node:'
    DO NI = 1,NETP%NNODE
       PRINT*, NI, NETP%NODENODE(NI,1:NETP%NODEDEG(NI))
    ENDDO
    
  END SUBROUTINE TESTNETWORKFROMFILE

  SUBROUTINE TESTSTEPFROMNODE
    ! test subroutine for a single propagation step from a  node

    IMPLICIT NONE
    INTEGER :: NID, LEAVENODE, LEAVEEDGE
    DOUBLE PRECISION :: LEAVELEN
    INTEGER :: TC
    
    NID = 5
    !CALL NETWORKFROMFILE(NETP,NETFILE)
    CALL TESTNETWORKFROMFILE

    PRINT*, 'NEXT PARTICLE POSITIONS:'
    DO TC = 1,NPART
       CALL STEPFROMNODE(NETP,NID,1D0,DELT,LEAVENODE, LEAVEEDGE, LEAVELEN)
       PRINT*, TC, LEAVENODE, LEAVEEDGE, LEAVELEN, DELT
    ENDDO
  END SUBROUTINE TESTSTEPFROMNODE
 
END PROGRAM MAIN