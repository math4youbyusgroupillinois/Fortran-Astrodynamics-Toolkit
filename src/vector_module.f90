!*****************************************************************************************
    module vector_module
!*****************************************************************************************
!****h* FAT/vector_module
!
!  NAME
!    vector_module
!
!  DESCRIPTION
!    Routines for the manipulation of vectors.
!
!*****************************************************************************************

    use kind_module,    only: wp
    use numbers_module, only: one,zero,pi
    
    implicit none
    
    private
    
    integer,parameter,public :: x_axis = 1
    integer,parameter,public :: y_axis = 2
    integer,parameter,public :: z_axis = 3
    
    public :: cross
    public :: unit
    public :: uhat_dot
    public :: ucross
    public :: axis_angle_rotation
    public :: cross_matrix
    public :: outer_product
    public :: box_product
    public :: vector_projection
    public :: axis_angle_rotation_to_rotation_matrix
    public :: spherical_to_cartesian
    public :: rotation_matrix
    
    !test routine:
    public :: vector_test
    
    contains
!*****************************************************************************************
    
!*****************************************************************************************
!****f* vector_module/cross
!
!  NAME
!    cross
!
!  DESCRIPTION
!    Cross product of two 3x1 vectors
!
!  AUTHOR
!    Jacob Williams
!
!  SOURCE

    pure function cross(r,v) result(rxv)

    implicit none

    real(wp),dimension(3),intent(in) :: r
    real(wp),dimension(3),intent(in) :: v
    real(wp),dimension(3)            :: rxv

    rxv = [r(2)*v(3) - v(2)*r(3), &
           r(3)*v(1) - v(3)*r(1), &
           r(1)*v(2) - v(1)*r(2) ]

    end function cross
!*****************************************************************************************

!*****************************************************************************************
!****f* vector_module/unit
!
!  NAME
!    unit
!
!  DESCRIPTION
!    Unit vector
!
!  AUTHOR
!    Jacob Williams
!
!  SOURCE

    pure function unit(r) result(u)

    implicit none

    real(wp),dimension(:),intent(in) :: r
    real(wp),dimension(size(r))      :: u

    real(wp) :: rmag

    rmag = norm2(r)

    if (rmag==zero) then
        u = zero
    else
        u = r / rmag
    end if

    end function unit
!*****************************************************************************************

!*****************************************************************************************
!****f* vector_module/uhat_dot
!
!  NAME
!    unit
!
!  DESCRIPTION
!    Time derivative of a unit vector.
!
!  AUTHOR
!    Jacob Williams
!
!  SOURCE

    pure function uhat_dot(u,udot) result(uhatd)

    implicit none

    real(wp),dimension(3),intent(in) :: u      ! vector [u]
    real(wp),dimension(3),intent(in) :: udot   ! derivative of vector [du/dt]
    real(wp),dimension(3)            :: uhatd  ! derivative of unit vector [d(uhat)/dt]

    real(wp)              :: umag  !vector magnitude 
    real(wp),dimension(3) :: uhat  !unit vector

    umag = norm2(u)

    if (umag == zero) then  !singularity
        uhatd = zero
    else
        uhat = u / umag
        uhatd = ( udot - dot_product(uhat,udot)*uhat ) / umag
    end if

    end function uhat_dot 
!*****************************************************************************************
    
!*****************************************************************************************
!****f* vector_module/ucross
!
!  NAME
!    ucross
!
!  DESCRIPTION
!    Unit vector of the cross product of two 3x1 vectors
!
!  AUTHOR
!    Jacob Williams
!
!  SOURCE

    pure function ucross(v1,v2) result(u)

    implicit none

    real(wp),dimension(3),intent(in) :: v1
    real(wp),dimension(3),intent(in) :: v2
    real(wp),dimension(3)            :: u

    u = unit(cross(v1,v2))

    end function ucross
!*****************************************************************************************
    
!*****************************************************************************************
!****f* vector_module/axis_angle_rotation
!
!  NAME
!    axis_angle_rotation
!
!  DESCRIPTION
!    Rotate a 3x1 vector in space, given an axis and angle of rotation. 
!
!  SEE ALSO
!    http://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
!
!  AUTHOR
!    Jacob Williams, 7/20/2014
!
!  SOURCE

    pure subroutine axis_angle_rotation(v,k,theta,vrot)
    
    implicit none
    
    real(wp),dimension(3),intent(in)  :: v      !vector to rotate
    real(wp),dimension(3),intent(in)  :: k      !rotation axis
    real(wp),intent(in)               :: theta  !rotation angle [rad]
    real(wp),dimension(3),intent(out) :: vrot   !result
    
    real(wp),dimension(3) :: khat
    real(wp) :: ct,st
    
    ct = cos(theta)
    st = sin(theta)      
    khat = unit(k)   !rotation axis unit vector
    
    vrot = v*ct + cross(khat,v)*st + khat*dot_product(khat,v)*(one-ct)
     
    end subroutine axis_angle_rotation
!*****************************************************************************************

!*****************************************************************************************
!****f* vector_module/cross_matrix
!
!  NAME
!    cross_matrix
!
!  DESCRIPTION
!    Computes the cross product matrix, where:
!      cross(a,b) == matmul(cross_matrix(a),b)
!
!  AUTHOR
!    Jacob Williams, 7/20/2014
!
!  SOURCE

    pure function cross_matrix(r) result(rcross)
    
    implicit none
    
    real(wp),dimension(3),intent(in) :: r 
    real(wp),dimension(3,3)          :: rcross
    
    rcross(:,1) = [zero,r(3),-r(2)]
    rcross(:,2) = [-r(3),zero,r(1)]
    rcross(:,3) = [r(2),-r(1),zero]
    
    end function cross_matrix
!*****************************************************************************************

!*****************************************************************************************
!****f* vector_module/outer_product
!
!  NAME
!    outer_product
!
!  DESCRIPTION
!    Computes the outer product of the two vectors.
!
!  AUTHOR
!    Jacob Williams, 7/21/2014
!
!  SOURCE

    pure function outer_product(a,b) result(c)
    
    implicit none
    
    real(wp),dimension(:),intent(in) :: a
    real(wp),dimension(:),intent(in) :: b
    real(wp),dimension(size(a),size(b)) :: c
    
    integer :: i
    
    do i=1,size(b)    
        c(:,i) = a*b(i)
    end do    
    
    end function outer_product
!*****************************************************************************************

!*****************************************************************************************
!****f* vector_module/box_product
!
!  NAME
!    outer_product
!
!  DESCRIPTION
!    Computes the box product (scalar triple product) of the three vectors.
!
!  AUTHOR
!    Jacob Williams, 7/21/2014
!
!  SOURCE

    pure function box_product(a,b,c) result(d)
    
    implicit none
    
    real(wp),dimension(:),intent(in) :: a
    real(wp),dimension(:),intent(in) :: b
    real(wp),dimension(:),intent(in) :: c
    real(wp) :: d
    
    d = dot_product(a,cross(b,c))  
    
    end function box_product
!*****************************************************************************************

!*****************************************************************************************
!****f* vector_module/vector_projection
!
!  NAME
!    vector_projection
!
!  DESCRIPTION
!    The projection of one vector onto another vector.
!
!  SEE ALSO
!    [1] http://en.wikipedia.org/wiki/Gram-Schmidt_process
!
!  AUTHOR
!    Jacob Williams, 7/21/2014
!
!  SOURCE

    pure function vector_projection(a,b) result(c)
    
    implicit none
    
    real(wp),dimension(:),intent(in)       :: a  !the original vector
    real(wp),dimension(size(a)),intent(in) :: b  !the vector to project on to
    real(wp),dimension(size(a))            :: c  !the projection of a onto b
    
    real(wp) :: amag2
    
    amag2 = dot_product(a,a)
    
    if (amag2==zero) then
        c = zero
    else
        c = a * dot_product(a,b) / amag2
    end if
    
    end function vector_projection
!*****************************************************************************************

!*****************************************************************************************
!****f* vector_module/axis_angle_rotation_to_rotation_matrix
!
!  NAME
!    axis_angle_rotation_to_rotation_matrix
!
!  DESCRIPTION
!    Computes the rotation matrix that corresponds to a 
!      rotation about the axis k by an angle theta.
!
!  AUTHOR
!    Jacob Williams, 7/20/2014
!
!  SOURCE

    pure subroutine axis_angle_rotation_to_rotation_matrix(k,theta,rotmat)
    
    implicit none
    
    real(wp),dimension(3),intent(in)    :: k        !rotation axis
    real(wp),intent(in)                 :: theta    !rotation angle [rad]
    real(wp),dimension(3,3),intent(out) :: rotmat   !rotation matrix
    
    !3x3 identity matrix:
    real(wp),dimension(3,3),parameter :: I = &
            reshape([one,zero,zero,zero,one,zero,zero,zero,one],[3,3])

    real(wp),dimension(3,3) :: w
    real(wp),dimension(3) :: khat
    real(wp) :: ct,st

    ct = cos(theta)
    st = sin(theta)  
    khat = unit(k)
    w  = cross_matrix(khat)
    
    rotmat = I + w*st + matmul(w,w)*(one-ct)
       
    end subroutine axis_angle_rotation_to_rotation_matrix
!*****************************************************************************************

!*****************************************************************************************
!****f* vector_module/spherical_to_cartesian
!
!  NAME
!    spherical_to_cartesian
!
!  DESCRIPTION
!    Convert spherical (r,alpha,beta) to Cartesian (x,y,z).
!
!  AUTHOR
!    Jacob Williams : 9/24/2014
!
!  SOURCE

    pure function spherical_to_cartesian(r,alpha,beta) result(rvec)
    
    implicit none
    
    real(wp),intent(in) :: r        ! magnitude
    real(wp),intent(in) :: alpha    ! right ascension [rad]
    real(wp),intent(in) :: beta     ! declination [rad]
    real(wp),dimension(3) :: rvec   ! [x,y,z] vector

    rvec(1) = r * cos(alpha) * cos(beta)
    rvec(2) = r * sin(alpha) * cos(beta)
    rvec(3) = r * sin(beta)

    end function spherical_to_cartesian
!*****************************************************************************************

!*****************************************************************************************
!****f* vector_module/rotation_matrix
!
!  NAME
!    rotation_matrix
!
!  DESCRIPTION
!    The 3x3 rotation matrix for a rotation about the x, y, or z-axis.
!
!  EXAMPLE
!    real(wp),dimension(3,3) :: rotmat
!    real(wp),dimension(3) :: vec,vec2
!    real(wp) :: ang
!    ang = pi / 4.0_wp
!    vec = [1.414_wp, 0.0_wp, 0.0_wp]
!    rotmat = rotation_matrix(z_axis,ang)
!    vec2 = matmul(rotmat,vec)
!
!  AUTHOR
!    Jacob Williams, 2/3/2015
!
!  SOURCE

    pure function rotation_matrix(axis,angle) result(rotmat)

    implicit none
    
    real(wp),dimension(3,3) :: rotmat   !the rotation matrix
    integer,intent(in)      :: axis     !x_axis, y_axis, or z_axis
    real(wp),intent(in)     :: angle    !angle in radians
    
    real(wp) :: c,s
    
    !precompute these:
    c = cos(angle)
    s = sin(angle)
    
    select case (axis)
    case(x_axis); rotmat = reshape([one, zero, zero, zero, c, -s, zero, s, c],[3,3])
    case(y_axis); rotmat = reshape([c, zero, s, zero, one, zero, -s, zero, c],[3,3])
    case(z_axis); rotmat = reshape([c, -s, zero, s, c, zero, zero, zero, one],[3,3])
    case default; rotmat = zero
    end select
    
    end function rotation_matrix
!*****************************************************************************************
    
!*****************************************************************************************
!****f* vector_module/vector_test
!
!  NAME
!    vector_test
!
!  DESCRIPTION
!    Unit test routine for the vector module.
!
!  AUTHOR
!    Jacob Williams, 7/20/2014
!
!  SOURCE

    subroutine vector_test()
    
    implicit none
    
    integer :: i
    real(wp) :: theta
    real(wp),dimension(3) :: v,k,v2,v3
    real(wp),dimension(3,3) :: rotmat

    write(*,*) ''
    write(*,*) '---------------'
    write(*,*) ' vector_test'
    write(*,*) '---------------'
    write(*,*) ''
    
    v = [1.2_wp, 3.0_wp, -5.0_wp]
    k = [-0.1_wp, 16.2_wp, 2.1_wp]
    theta = 0.123_wp
    
    call axis_angle_rotation(v,k,theta,v2)
    
    call axis_angle_rotation_to_rotation_matrix(k,theta,rotmat)
    v3 = matmul(rotmat,v)
    
    write(*,*) 'Single test:'
    write(*,*) ''
    write(*,*) '  v1   :', v
    write(*,*) '  v2   :', v2
    write(*,*) '  v3   :', v3    
    write(*,*) '  Error:', v3-v2
    
    write(*,*) ''
    write(*,*) '0-360 test:'
    write(*,*) ''
    do i=0,360,10
    
        theta = i * 180.0_wp/pi
        
        call axis_angle_rotation(v,k,theta,v2)
    
        call axis_angle_rotation_to_rotation_matrix(k,theta,rotmat)
        v3 = matmul(rotmat,v)
            
        write(*,*) 'Error:', norm2(v3-v2)
        
    end do
    
    !z-axis rotation test:
    theta = pi / 4.0_wp
    v = [one/cos(theta), 0.0_wp, 0.0_wp]
    rotmat = rotation_matrix(z_axis,theta)
    v2 = matmul(rotmat,v)
    write(*,*) v2    !should be [1, -1, 0]

    
    end subroutine vector_test
 !*****************************************************************************************
   
!*****************************************************************************************
    end module vector_module
!*****************************************************************************************