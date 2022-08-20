// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// create_graph_rcpp
int create_graph_rcpp(int nvertices, IntegerVector src, IntegerVector dst);
RcppExport SEXP _fastnetworklib_create_graph_rcpp(SEXP nverticesSEXP, SEXP srcSEXP, SEXP dstSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< int >::type nvertices(nverticesSEXP);
    Rcpp::traits::input_parameter< IntegerVector >::type src(srcSEXP);
    Rcpp::traits::input_parameter< IntegerVector >::type dst(dstSEXP);
    rcpp_result_gen = Rcpp::wrap(create_graph_rcpp(nvertices, src, dst));
    return rcpp_result_gen;
END_RCPP
}
// create_graphw_rcpp
int create_graphw_rcpp(int nvertices, IntegerVector src, IntegerVector dst, NumericVector weights);
RcppExport SEXP _fastnetworklib_create_graphw_rcpp(SEXP nverticesSEXP, SEXP srcSEXP, SEXP dstSEXP, SEXP weightsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< int >::type nvertices(nverticesSEXP);
    Rcpp::traits::input_parameter< IntegerVector >::type src(srcSEXP);
    Rcpp::traits::input_parameter< IntegerVector >::type dst(dstSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type weights(weightsSEXP);
    rcpp_result_gen = Rcpp::wrap(create_graphw_rcpp(nvertices, src, dst, weights));
    return rcpp_result_gen;
END_RCPP
}
// free_graph_rcpp
void free_graph_rcpp(int graphid);
RcppExport SEXP _fastnetworklib_free_graph_rcpp(SEXP graphidSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< int >::type graphid(graphidSEXP);
    free_graph_rcpp(graphid);
    return R_NilValue;
END_RCPP
}
// free_all_graphs_rcpp
void free_all_graphs_rcpp();
RcppExport SEXP _fastnetworklib_free_all_graphs_rcpp() {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    free_all_graphs_rcpp();
    return R_NilValue;
END_RCPP
}
// connected_components_rcpp
IntegerVector connected_components_rcpp(int graphid);
RcppExport SEXP _fastnetworklib_connected_components_rcpp(SEXP graphidSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< int >::type graphid(graphidSEXP);
    rcpp_result_gen = Rcpp::wrap(connected_components_rcpp(graphid));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_fastnetworklib_create_graph_rcpp", (DL_FUNC) &_fastnetworklib_create_graph_rcpp, 3},
    {"_fastnetworklib_create_graphw_rcpp", (DL_FUNC) &_fastnetworklib_create_graphw_rcpp, 4},
    {"_fastnetworklib_free_graph_rcpp", (DL_FUNC) &_fastnetworklib_free_graph_rcpp, 1},
    {"_fastnetworklib_free_all_graphs_rcpp", (DL_FUNC) &_fastnetworklib_free_all_graphs_rcpp, 0},
    {"_fastnetworklib_connected_components_rcpp", (DL_FUNC) &_fastnetworklib_connected_components_rcpp, 1},
    {NULL, NULL, 0}
};

RcppExport void R_init_fastnetworklib(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
