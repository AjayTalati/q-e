!
! Copyright (C) 2001-2008 Quantum-ESPRESSO group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
!
!---------------------------------------------------------------------
subroutine syme2 (dvsym)
  !-------------------------------------------------------------------
  !
  ! This routine symmetrizes the second order derivative of a scalar
  ! funtion read in input, with respect to electric field perturbations.
  ! The function in input has only the six independent components.
  ! The correspondence between the six components and the matrix elements of
  ! the symmetric 3x3 tensor are given by the common variables: jab; a1j; a2j
  !
#include "f_defs.h"
  use kinds,  only : DP
  USE gvect,  ONLY: nrx1,nrx2,nrx3, nr1,nr2,nr3
  USE symme,  ONLY: nsym, s, ftau
  USE ramanm, ONLY: jab
  implicit none

  complex(DP) :: dvsym (nrx1, nrx2, nrx3, 6)
  complex(DP), allocatable :: aux (:,:,:,:)
  ! the function to symmetrize
  ! auxiliary space

  integer :: ix, jx, kx, ri, rj, rk, irot, ip, jp, lp, mp
  ! define a real-space point on the grid
  ! the rotated points
  ! counter on symmetries
  ! counter on polarizations

  if (nsym.eq.1) return
  allocate (aux(nrx1 , nrx2 , nrx3 , 6))

  do ip = 1, 6
     call ZCOPY (nrx1 * nrx2 * nrx3, dvsym (1, 1, 1, ip), &
                 1, aux (1, 1, 1, ip), 1)
  enddo
  dvsym (:,:,:,:) = (0.d0, 0.d0)
  !
  !  symmmetrize 
  !
  do kx = 1, nr3
  do jx = 1, nr2
  do ix = 1, nr1
     do irot = 1, nsym
        call ruotaijk(s (1, 1, irot), ftau (1, irot), ix, jx, kx, &
                      nr1, nr2, nr3, ri, rj, rk)
        !
        ! ruotaijk finds the rotated of ix,jx,kx with the inverse of S
        !
        do ip = 1, 3
        do jp = 1, ip
           do lp = 1, 3
           do mp = 1, 3
              dvsym (ix, jx, kx, jab (ip, jp)) = &
              dvsym (ix, jx, kx, jab (ip, jp)) + &
                 DBLE (s (ip, lp, irot))* &
                 DBLE (s (jp, mp, irot))* &
                 aux (ri, rj, rk, jab(lp, mp))
           enddo
           enddo
        enddo
        enddo
     enddo
  enddo
  enddo
  enddo

  do ip = 1, 6
     call DSCAL (2 * nrx1 * nrx2 * nrx3, 1.d0 / DBLE (nsym), &
                 dvsym (1, 1, 1, ip), 1)
  enddo

  deallocate (aux)
  return
end subroutine syme2
