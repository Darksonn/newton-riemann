
/*
  Class for dual numbers.
  Dual numbers exhibit the following property for any analytic function f:
    f(dual(x, 1)) = dual(f(x), f'(x))
  This makes them useful for calculating the value and derivative of a function.
 */
template <typename T>
class dual {
  public:
    T a, b;
    typedef T value_type;

    inline __host__ __device__
    dual(const T & _a = T(), const T & _b = T()) {
      a = _a;
      b = _b;
    }

    inline __host__ __device__
    dual<T> operator+(const dual<T> that) const {
      dual<T> out;
      out.a = a + that.a;
      out.b = b + that.b;
      return out;
    }
    inline __host__ __device__
    dual<T> operator-() const {
      dual<T> out;
      out.a = -a;
      out.b = -b;
      return out;
    }
    inline __host__ __device__
    dual<T> operator-(const dual<T> that) const {
      return operator+(-that);
    }
    inline __host__ __device__
    dual<T> operator*(const dual<T> that) const {
      dual<T> out;
      out.a = a * that.a;
      out.b = a * that.b + b * that.a;
      return out;
    }
    inline __host__ __device__
    dual<T> inverse() const {
      dual<T> out;
      out.a = T(1)/a;
      out.b = -b / (a*a);
      return out;
    }
    inline __host__ __device__
    dual<T> operator/(const dual<T> that) const {
      return operator*(that.inverse());
    }

};

template <typename T>
inline __host__ __device__
dual<T> dpow(dual<T> a, dual<T> b) {
  T one = T(1);
  T zero = T();
  dual<T> out;
  out.a = thrust::pow(a.a, b.a);
  out.b = b.a * a.b * thrust::pow(a.a, b.a-one);
  if (b.b != zero) out.b += b.b * out.a * thrust::log(a.a);
  return out;
}
template <typename T>
inline __host__ __device__
dual<T> dpown(dual<T> a, unsigned int n) {
  if (n == 0) return T(1);
  if (n == 1) return a;
  if (n % 2 == 0) return dpown(a*a, n / 2);
  return a * dpown(a*a, (n-1) / 2);
}
template <typename T>
inline __host__ __device__
dual<T> dlog(dual<T> x) {
  dual<T> out;
  out.a = thrust::log(x.a);
  out.b = x.b / x.a;
  return out;
}
template <typename T>
inline __host__ __device__
dual<T> dexp(dual<T> x) {
  dual<T> out;
  out.a = thrust::exp(x.a);
  out.b = x.b * out.a;
  return out;
}
template <typename T>
inline __host__ __device__
dual<T> dsin(dual<T> x) {
  dual<T> out;
  out.a = thrust::sin(x.a);
  out.b = x.b * thrust::cos(x.a);
  return out;
}
template <typename T>
inline __host__ __device__
dual<T> dcos(dual<T> x) {
  dual<T> out;
  out.a = thrust::cos(x.a);
  out.b = -x.b * thrust::sin(x.a);
  return out;
}
template <typename T>
inline __host__ __device__
dual<T> dtan(dual<T> x) {
  T one = T(1);
  T two = T(2);
  dual<T> out;
  out.a = thrust::tan(x.a);
  out.b = x.b * two / (cos(two*x.a)+one);
  return out;
}


